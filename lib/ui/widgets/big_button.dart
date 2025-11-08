import 'package:flutter/material.dart';
import 'package:she_sos/ui/widgets/themedata.dart';

class BigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BigButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: maincolor, // background color inside Material
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
