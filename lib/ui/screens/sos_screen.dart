import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _voiceMessage;
  File? _videoMessage;
  bool _isLoading = false;

  Map<String, double>? _location;

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _location = {"lat": pos.latitude, "lng": pos.longitude};
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _pickVoice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _voiceMessage = File(result.files.single.path!));
    }
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
    if (file != null) setState(() => _videoMessage = File(file.path));
  }

  Future<void> _sendEmergency() async {
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please allow location access first!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not signed in')),
        );
        return;
      }

      final messageId = const Uuid().v4();

      final messageData = {
        "userId": user.uid,
        "phone": user.phoneNumber ?? "Unknown",
        "profilePicture": user.photoURL,
        "name": user.displayName ?? "Anonymous",
        "gender": "Unknown",
        "age": 0,
        "messageId": messageId,
        "voiceMessage": _voiceMessage?.path, // Replace with Storage URL later
        "videoMessage": _videoMessage?.path,
        "timestamp": DateTime.now().toIso8601String(),
        "txtMessage": [_textController.text.trim()],
        "location": _location,
      };

      await FirebaseFirestore.instance
          .collection('helpNeed')
          .doc(messageId)
          .set(messageData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚨 SOS sent successfully!')),
      );

      _textController.clear();
      setState(() {
        _voiceMessage = null;
        _videoMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error uploading: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending SOS: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Help'),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "🚨 What's your emergency?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text message input
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Describe your emergency...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Voice / Video buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.mic),
                        label: Text(_voiceMessage == null
                            ? 'Add Voice'
                            : 'Voice Added'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                        ),
                        onPressed: _pickVoice,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.videocam),
                        label: Text(_videoMessage == null
                            ? 'Record Video'
                            : 'Video Added'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: _pickVideo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_location != null)
                    Text(
                      "📍 Location: ${_location!['lat']}, ${_location!['lng']}",
                      style: const TextStyle(color: Colors.black87),
                    ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _sendEmergency,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      "Send SOS",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
