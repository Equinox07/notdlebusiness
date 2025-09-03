import 'package:flutter/material.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final List<Map<String, String>> measurements = [
    {"client": "Emma Johnson", "bust": "34", "waist": "26", "hips": "36"},
    {"client": "Michael Chen", "chest": "40", "waist": "32", "inseam": "30"},
    {"client": "Lisa Rodriguez", "bust": "36", "waist": "28", "hips": "38"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Measurements")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          final data = measurements[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(data["client"]!),
              subtitle: Text(
                data.entries
                    .where((e) => e.key != "client")
                    .map((e) => "${e.key}: ${e.value}")
                    .join(" | "),
              ),
              trailing: const Icon(Icons.edit, color: Colors.grey),
              onTap: () => print("Edit measurements for ${data["client"]}"),
            ),
          );
        },
      ),
    );
  }
}