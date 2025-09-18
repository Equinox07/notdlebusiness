import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';

class OrderWithDetails {
  final Order order;
  final Customer customer;
  final Invoice invoice;

  OrderWithDetails(this.order, this.customer, this.invoice);
}
