import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final firestore = FirebaseFirestore.instance;

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (!(await Geolocator.isLocationServiceEnabled())) return;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final prefs = await SharedPreferences.getInstance();
    final sosId = prefs.getString('active_sos_id');

    if (sosId != null) {
      await firestore.collection('sos_alerts').doc(sosId).update({
        'lat': position.latitude,
        'lng': position.longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  });
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'sos_tracking',
      initialNotificationTitle: 'SheSOS Active',
      initialNotificationContent: 'Tracking your location for safety',
    ),
    iosConfiguration: IosConfiguration(),
  );
}
