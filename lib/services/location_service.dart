import 'dart:async';
import 'package:geolocator/geolocator.dart';


class LocationService {
Stream<Position> get positionStream => Geolocator.getPositionStream(
locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
);


Future<bool> ensurePermissions() async {
bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
if (!serviceEnabled) return false;


LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
permission = await Geolocator.requestPermission();
if (permission == LocationPermission.denied) return false;
}
if (permission == LocationPermission.deniedForever) return false;
return true;
}


Future<Position> getCurrent() => Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
}