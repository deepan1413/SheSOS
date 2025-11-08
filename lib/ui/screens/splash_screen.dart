import 'package:flutter/material.dart';
import 'package:she_sos/ui/screens/login_screen.dart';
import 'package:she_sos/ui/widgets/themedata.dart';
import 'package:she_sos/ui/widgets/titleFont.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    // Navigate to LoginScreen after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 150),
          Column(
            children: [
              TitleFont(name: 'She SoS',),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: maincolor),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Image.asset('assets/splashDown.png'),
          ),
        ],
      ),
    );
  }
}

