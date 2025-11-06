import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class VolunteerMapScreen extends StatefulWidget {
  const VolunteerMapScreen({super.key});

  @override
  State<VolunteerMapScreen> createState() => _VolunteerMapScreenState();
}

class _VolunteerMapScreenState extends State<VolunteerMapScreen> {
  Position? _position;
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenToSOSAlerts();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  void _listenToSOSAlerts() {
    FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      final newMarkers = <Marker>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['lat'] == null || data['lng'] == null) continue;

        newMarkers.add(Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['lat'], data['lng']),
          infoWindow: InfoWindow(
            title: data['email'] ?? 'Unknown User',
            snippet: 'Live SOS Alert',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      }
      setState(() => _markers
        ..clear()
        ..addAll(newMarkers));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active SOS Alerts'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_position!.latitude, _position!.longitude),
          zoom: 13,
        ),
        myLocationEnabled: true,
        onMapCreated: (controller) => _controller = controller,
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recenter,
        label: const Text("Recenter"),
        icon: const Icon(Icons.my_location),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future<void> _recenter() async {
    if (_controller == null || _position == null) return;
    await _controller!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(_position!.latitude, _position!.longitude),
      ),
    );
  }
}
