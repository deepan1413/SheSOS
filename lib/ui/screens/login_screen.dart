import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:she_sos/models/user_model.dart';
import 'package:she_sos/services/AuthServices.dart';
import 'package:she_sos/ui/screens/forget_password_screen.dart';

import 'package:she_sos/ui/widgets/big_button.dart';
import 'package:she_sos/ui/widgets/form_field.dart';
import 'package:she_sos/ui/widgets/themedata.dart';
import 'package:she_sos/ui/widgets/titleFont.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _loading = false;
  bool _isForgotPassword = true;

  Future<void> signInWithGoogle() async {
    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (!mounted) return;
      if (userCredential == null) {
        print(
          "${userCredential!.user?.email} ==========================signed in with Google",
        );
      } else {
        print("Google Sign-In failed or was cancelled.");
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  Future<void> _sendPasswordReset() async {}

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Optional: fetch user data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleFont(name: 'She SoS'),
              NewFormField(hintText: 'Email', controller: emailController),
              ?_isForgotPassword
                  ? NewFormField(
                      hintText: 'Password',
                      controller: passwordController,
                    )
                  : null,

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isForgotPassword = !_isForgotPassword;
                      });
                    },
                    child: Text(
                      'Forget Password?',
                      style: TextStyle(color: maincolor),
                    ),
                  ),
                ],
              ),

              BigButton(
                onPressed: _isForgotPassword ? _login : _sendPasswordReset,
                text: _isForgotPassword ? 'Login' : 'Send Reset Link',
              ),

              Text('or'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: maincolor,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () async {
                      await signInWithGoogle();
                    },
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    splashColor: Colors.white.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_logo.png',
                              height: 24,
                              width: 24,
                            ),

                            Text(
                              '  continue with Google',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text('Sign Up', style: TextStyle(color: maincolor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
