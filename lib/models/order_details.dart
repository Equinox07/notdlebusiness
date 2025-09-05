// lib/models/order_details.dart

import 'package:notdle/models/order.dart';

class OrderDetails {
  final Order order;
  final String customerPhone;
  final String customerEmail;
  final String paymentStatus;
  final String dueDate;
  final List<OrderEvent> timeline;
  final String? notes; // Optional notes field

  OrderDetails({
    required this.order,
    required this.customerPhone,
    required this.customerEmail,
    required this.paymentStatus,
    required this.dueDate,
    required this.timeline,
    this.notes, // Make the parameter optional
  });
}

class OrderEvent {
  final String title;
  final String date;
  final bool isCurrent;

  OrderEvent({required this.title, required this.date, this.isCurrent = false});
}
