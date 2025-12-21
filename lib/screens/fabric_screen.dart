import 'package:flutter/material.dart';
import 'package:notdle/widgets/custom_app_bar.dart';

class FabricsScreen extends StatelessWidget {
  const FabricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Fabrics"),
      body: const Center(child: Text("Fabric catalog here")),
    );
  }
}
