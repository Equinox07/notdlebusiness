import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/payment.dart';

class InvoiceWithPayments {
  final Invoice invoice;
  final List<Payment> payments;

  InvoiceWithPayments({required this.invoice, required this.payments});
}
