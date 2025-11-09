import 'package:flutter/material.dart';
import 'package:she_sos/ui/screens/help_screen.dart';
import 'package:she_sos/ui/screens/home_screen.dart';
import 'package:she_sos/ui/screens/profile_screen.dart';
import 'package:she_sos/ui/screens/sos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List screens = [
    const HomeScreen(),
    const SosScreen(),
    const HelpScreen(),
    // const ProfileScreen(user: null,),
  ];

  int _currentIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SheSOS")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Handle navigation tap
          setState(() {
            _currentIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.sos), label: "Help"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: screens[_currentIndex],
    );
  }
}
