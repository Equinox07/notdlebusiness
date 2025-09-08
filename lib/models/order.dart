// lib/models/order.dart
import 'package:uuid/uuid.dart';

class Order {
  final String id;
  final String title;
  final int customerId; // Foreign key
  final String status;
  final String paymentStatus;
  final double? paymentAmount;
  final String? dueDate;
  final String? notes;
  final String? invoiceId; // Link to the invoice
  final String createdDate; // New field


  Order({
    required this.title,
    required this.customerId,
    required this.status,
    required this.paymentStatus,
    this.paymentAmount,
    this.dueDate,
    this.notes,
    this.invoiceId,
    required this.createdDate, // Add to constructor
    String? id,
  }) : id = id ?? const Uuid().v4();

  // Convert an Order object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'customerId': customerId,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentAmount': paymentAmount,
      'dueDate': dueDate,
      'notes': notes,
      'invoiceId': invoiceId,
      'createdDate': createdDate,
    };
  }

  // Create an Order object from a Map.
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      title: map['title'],
      customerId: map['customerId'] as int,
      status: map['status'],
      paymentStatus: map['paymentStatus'],
      paymentAmount: map['paymentAmount'],
      dueDate: map['dueDate'],
      notes: map['notes'],
      invoiceId: map['invoiceId'],
      createdDate: map['createdDate'] as String,
    );
  }
}
