// lib/models/order_details.dart

import 'package:notdle/models/order.dart';
import 'package:notdle/models/order_event.dart';

class OrderDetails {
  final Order order;
  final String customerPhone;
  final String customerEmail;
  final String paymentStatus;
  final String dueDate;
  final List<OrderEvent> timeline;
  final String? notes;
  final String? companyId;
  final String? userId;

  OrderDetails({
    required this.order,
    required this.customerPhone,
    required this.customerEmail,
    required this.paymentStatus,
    required this.dueDate,
    required this.timeline,
    this.notes,
    this.companyId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': order.id,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'paymentStatus': paymentStatus,
      'dueDate': dueDate,
      'notes': notes,
      'companyId': companyId,
      'userId': userId,
    };
  }

  static OrderDetails fromMap(
    Map<String, dynamic> map,
    Order order,
    List<OrderEvent> timeline,
  ) {
    return OrderDetails(
      order: order,
      customerPhone: map['customerPhone'],
      customerEmail: map['customerEmail'],
      paymentStatus: map['paymentStatus'],
      dueDate: map['dueDate'],
      timeline: timeline,
      notes: map['notes'],
      companyId: map['companyId'],
      userId: map['userId'],
    );
  }
}
