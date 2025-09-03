

import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, String>> orders = [
    {"order": "Wedding Dress", "client": "Emma Johnson", "status": "In Progress"},
    {"order": "Business Suit", "client": "Michael Chen", "status": "Completed"},
    {"order": "Blazer", "client": "Lisa Rodriguez", "status": "Pending"},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(order["status"]!).withOpacity(0.2),
                child: Icon(Icons.shopping_bag,
                    color: _statusColor(order["status"]!)),
              ),
              title: Text(order["order"]!),
              subtitle: Text(order["client"]!),
              trailing: Text(
                order["status"]!,
                style: TextStyle(
                  color: _statusColor(order["status"]!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}