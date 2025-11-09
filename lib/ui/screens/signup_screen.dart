import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:she_sos/models/user_model.dart';
import 'package:she_sos/ui/widgets/big_button.dart';
import 'package:she_sos/ui/widgets/form_field.dart';
import 'package:she_sos/ui/widgets/titleFont.dart';
import 'home_screen.dart';

enum Gender { Male, Female }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isVolunteer = false;

  bool _loading = false;
  Gender? _selectedGender;

  Future<void> _signup() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select gender")));
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) Create Firebase Auth user
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = cred.user!.uid;

      // 2) Create User Model
      final user = UserModel(
        userId: uid,
        name: _nameController.text.trim(),
        emailId: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: "",
        profilePicture: null,
        isVolunteer: _isVolunteer,
        emergencyContacts: [],
        currentLocation: null,
        isSafe: true,
      );

      // 3) Save to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(user.toMap());

      print("✅ User Created:");
      print(user.toMap());

      // 4) Navigate to home
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleFont(name: 'Create Account'),
              const SizedBox(height: 30),
              NewFormField(controller: _nameController, hintText: 'name'),
              NewFormField(controller: _emailController, hintText: 'Email'),
              NewFormField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              NewFormField(controller: _phoneController, hintText: 'Phone'),
              Row(
                children: [
                  Checkbox(
                    value: _isVolunteer,
                    onChanged: (value) {
                      setState(() {
                        _isVolunteer = !_isVolunteer;
                      });
                    },
                  ),
                  const Text('Sign up as Volunteer'),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: Radio<Gender>(
                        value: Gender.Male,
                        groupValue: _selectedGender,
                        onChanged: (Gender? val) {
                          setState(() {
                            _selectedGender = val;
                          });
                        },
                      ),
                      title: const Text('Male'),
                      onTap: () {
                        setState(() {
                          _selectedGender = Gender.Male;
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: ListTile(
                      leading: Radio<Gender>(
                        value: Gender.Female,
                        groupValue: _selectedGender,
                        onChanged: (Gender? val) {
                          setState(() {
                            _selectedGender = val;
                          });
                        },
                      ),
                      title: const Text('Female'),
                      onTap: () {
                        setState(() {
                          _selectedGender = Gender.Female;
                        });
                      },
                    ),
                  ),
                ],
              ),

              _loading
                  ? const CircularProgressIndicator()
                  : BigButton(onPressed: () => _signup(), text: 'Sign Up'),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
