import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:she_sos/models/user_model.dart';
import 'package:she_sos/ui/screens/profile_screen.dart';
import 'package:she_sos/ui/screens/sos_screen.dart';
import 'package:she_sos/ui/widgets/swipe_button.dart';
import 'package:she_sos/ui/widgets/titleFont.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    updateUserLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });
  }

  Future<UserModel?> _fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUserLocation() async {
    try {
      // Ensure user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("⚠️ No authenticated user found.");
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Build location map
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      // Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'currentLocation': locationData,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      print("✅ User location updated successfully: $locationData");
    } catch (e) {
      print("❌ Failed to update location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // drawer: Drawer(
      //   child: FutureBuilder<UserModel?>(
      //     future: _fetchUser(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return const Center(child: CircularProgressIndicator());
      //       }
      //       if (snapshot.hasError) {
      //         return const Center(child: Text("Error loading user"));
      //       }

      //       final userModel = snapshot.data;
      //       if (userModel == null) {
      //         return const Center(child: Text("User not found"));
      //       }

      //       return Column(
      //         children: [
      //           DrawerHeader(
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 CircleAvatar(
      //                   radius: 40,
      //                   backgroundImage: userModel.profilePicture != null
      //                       ? NetworkImage(userModel.profilePicture!)
      //                       : null,
      //                   child: userModel.profilePicture == null
      //                       ? const Icon(Icons.person, size: 40)
      //                       : null,
      //                 ),
      //                 const SizedBox(height: 8),
      //                 TitleFont(name: "SheSOS"),
      //               ],
      //             ),
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.person),
      //             title: const Text("Profile"),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (_) => ProfileScreen(user: userModel),
      //                 ),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.settings),
      //             title: const Text("Settings"),
      //             onTap: () {},
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.logout),
      //             title: const Text("Sign Out"),
      //             onTap: () async {
      //               await FirebaseAuth.instance.signOut();
      //               if (context.mounted) {
      //                 Navigator.pop(context);
      //               }
      //             },
      //           ),
      //         ],
      //       );
      //     },
      //   ),
      // ),
      body: Stack(
        children: [
          _loading || _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),

          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${user?.displayName ?? 'User'}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  FutureBuilder<UserModel?>(
                    future: _fetchUser(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Checking status...");
                      }
                      final userData = snapshot.data!;
                      return Text(
                        "Current Status: ${userData.isSafe ? 'Safe' : 'In Danger'}",
                        style: TextStyle(
                          fontSize: 16,
                          color: userData.isSafe ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: SwipeButton(
                      text: 'Swipe for SOS',
                      onSwipe: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SosScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
