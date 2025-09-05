// lib/models/invoice.dart
import 'package:uuid/uuid.dart';

class Invoice {
  final String id;
  final String title;
  final String customerId; // Foreign key
  final String status;
  final double totalAmount;
  final DateTime date;
  final String orderId; // Foreign key to the related order

  Invoice({
    required this.title,
    required this.customerId,
    required this.status,
    required this.totalAmount,
    required this.date,
    required this.orderId,
    String? id,
  }) : id = id ?? const Uuid().v4();

  // Convert an Invoice object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'customerId': customerId,
      'status': status,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(), // Store date as a string
      'orderId': orderId,
    };
  }

  // Create an Invoice object from a Map.
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      title: map['title'],
      customerId: map['customerId'],
      status: map['status'],
      totalAmount: map['totalAmount'],
      date: DateTime.parse(map['date']),
      orderId: map['orderId'],
    );
  }
}
