import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:she_sos/services/location_service.dart';


class FirebaseService {
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;
final _location = LocationService();


Future<void> createSos({required String sosId, required String message, File? mediaFile}) async {
final pos = await _location.getCurrent();
String? mediaUrl;
if (mediaFile != null) {
final task = await _storage.ref('sos/$sosId/${DateTime.now().millisecondsSinceEpoch}').putFile(mediaFile);
mediaUrl = await task.ref.getDownloadURL();
}


await _firestore.collection('sos').doc(sosId).set({
'message': message,
'lat': pos.latitude,
'lng': pos.longitude,
'createdAt': FieldValue.serverTimestamp(),
'mediaUrl': mediaUrl,
'status': 'open',
});
}
}