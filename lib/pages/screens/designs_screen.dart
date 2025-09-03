import 'package:flutter/material.dart';

class DesignsScreen extends StatefulWidget {
  const DesignsScreen({super.key});

  @override
  State<DesignsScreen> createState() => _DesignsScreenState();
}

class _DesignsScreenState extends State<DesignsScreen> {
  final List<Map<String, dynamic>> designs = [
    {"name": "Evening Gown", "color": Colors.purple},
    {"name": "Casual Dress", "color": Colors.orange},
    {"name": "Business Suit", "color": Colors.blue},
    {"name": "Traditional Wear", "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Designs")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: designs.length,
        itemBuilder: (context, index) {
          final design = designs[index];
          return Container(
            decoration: BoxDecoration(
              color: design["color"].withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: design["color"], width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.palette, size: 40, color: design["color"]),
                const SizedBox(height: 12),
                Text(
                  design["name"],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: design["color"]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}