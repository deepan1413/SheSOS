import 'package:flutter/material.dart';

class NewFormField extends StatelessWidget {
  const NewFormField({
    super.key,
    required this.emailController,
    required this.hintText,
  });

  final TextEditingController emailController;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }
}
