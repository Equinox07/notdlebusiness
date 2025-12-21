import 'package:flutter/material.dart';
import 'package:notdle/widgets/custom_app_bar.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Projects"),
      body: const Center(child: Text("Projects overview here")),
    );
  }
}
