// lib/models/order.dart

import 'package:notdle/models/customer.dart';

class Order {
  final String id;
  final String title;
  final Customer customer; // Use the Customer model directly
  final String status;

  Order({
    required this.id,
    required this.title,
    required this.customer,
    required this.status,
  });
}
