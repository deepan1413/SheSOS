import 'package:flutter/material.dart';
import 'package:she_sos/ui/widgets/themedata.dart';

class TitleFont extends StatelessWidget {
   TitleFont({super.key, required this.name});
  String name;
  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: maincolor,
      ),
    );
  }
}
