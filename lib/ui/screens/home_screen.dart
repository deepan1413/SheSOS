import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:she_sos/services/background_service.dart';
import 'package:she_sos/ui/screens/volunteer_map_screen.dart';
import 'package:she_sos/ui/widgets/sos_button.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  final AudioRecorder _recorder = AudioRecorder();
  Position? _position;
  bool _sending = false;
  double _lastVolume = 0;
  DateTime? _lastVolumePress;
  StreamSubscription<AccelerometerEvent>? _shakeSub;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initLocation();
    _initShakeDetection();
    _initVolumeListener();
  }

  // ---------------- CAMERA ----------------
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  // ---------------- LOCATION ----------------
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    _position = await Geolocator.getCurrentPosition();
  }

  // ---------------- SHAKE DETECTION ----------------
  void _initShakeDetection() {
    const double threshold = 25.0;
    double lastX = 0, lastY = 0, lastZ = 0;

    _shakeSub = accelerometerEvents.listen((AccelerometerEvent event) {
      double dx = event.x - lastX;
      double dy = event.y - lastY;
      double dz = event.z - lastZ;
      double speed = dx * dx + dy * dy + dz * dz;

      if (speed > threshold) {
        _triggerSOS();
      }

      lastX = event.x;
      lastY = event.y;
      lastZ = event.z;
    });
  }

  // ---------------- VOLUME LISTENER ----------------
  void _initVolumeListener() {
    VolumeController().listener((volume) {
      final now = DateTime.now();

      if ((now.difference(_lastVolumePress ?? now).inMilliseconds < 600) &&
          (volume != _lastVolume)) {
        _triggerSOS();
      }

      _lastVolumePress = now;
      _lastVolume = volume;
    });
  }

  // ---------------- MAIN SOS TRIGGER ----------------
  Future<void> _triggerSOS() async {
    if (_sending) return;
    setState(() => _sending = true);

    try {
      await _initLocation();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Take picture
      final file = await _cameraController!.takePicture();
      final photo = File(file.path);
      final savePath = '${Directory.systemTemp.path}/sos_audio.m4a';

      // Record audio 5sec
      if (await _recorder.hasPermission()) {
        await Future.delayed(const Duration(seconds: 5));
        final audioPath = await _recorder.stop();

        if (audioPath != null) {
          await _uploadSOS(user, photo, File(audioPath));
        }
      } else {
        await _uploadSOS(user, photo, null);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 SOS Alert Sent to Volunteers'),
            backgroundColor: Colors.pink,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  // ---------------- FIRESTORE UPLOAD ----------------
  Future<void> _uploadSOS(User user, File photo, File? audio) async {
    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload photo
    final photoRef = storage.ref('sos/$id/photo.jpg');
    await photoRef.putFile(photo);
    final photoUrl = await photoRef.getDownloadURL();

    String? audioUrl;
    if (audio != null) {
      final audioRef = storage.ref('sos/$id/audio.m4a');
      await audioRef.putFile(audio);
      audioUrl = await audioRef.getDownloadURL();
    }

    await firestore.collection('sos_alerts').doc(id).set({
      'userId': user.uid,
      'email': user.email,
      'lat': _position?.latitude,
      'lng': _position?.longitude,
      'photoUrl': photoUrl,
      'audioUrl': audioUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });

    await prefs.setString('active_sos_id', id);

    // Start background service for live tracking
    await initializeBackgroundService();
    final service = FlutterBackgroundService();
    service.startService();
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    VolumeController().removeListener();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SheSOS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VolunteerMapScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome ${user?.email ?? ''}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            SosButton(onPressed: _triggerSOS),
            const SizedBox(height: 30),
            _sending
                ? const CircularProgressIndicator()
                : const Text("Triggers: Volume, Shake, or Button"),
          ],
        ),
      ),
    );
  }
}
