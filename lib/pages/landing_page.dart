import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const String tag = "landing";

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(
      child: Text("Welcome"),
    ),);
  }
}