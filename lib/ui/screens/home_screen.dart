import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:she_sos/ui/screens/volunteer_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${user?.email ?? 'User'}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
