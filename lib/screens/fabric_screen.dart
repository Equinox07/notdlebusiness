import 'package:flutter/material.dart';

class FabricsScreen extends StatelessWidget {
  const FabricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fabrics")),
      body: const Center(child: Text("Fabric catalog here")),
    );
  }
}
