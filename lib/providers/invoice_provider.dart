import 'package:flutter/material.dart';
import 'package:notdle/models/dao/invoice_dao.dart';
import 'package:notdle/utils/helpers.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/order.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceDao invoiceDao;

  InvoiceProvider({required this.invoiceDao});

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  Future<void> fetchInvoices() async {
    _invoices = await invoiceDao.getAllInvoices();
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await invoiceDao.insertInvoice(invoice);
    await fetchInvoices();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await invoiceDao.updateInvoice(invoice);
    await fetchInvoices();
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    await invoiceDao.deleteInvoice(invoice);
    await fetchInvoices();
  }

  /// ✅ Auto-generate an invoice from an order
  Future<void> createInvoiceFromOrder(Order order) async {
    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: generateInvoiceNumber(),
      title: 'Invoice for ${order.title}',
      customerId: order.customerId,
      status: 'unpaid',
      totalAmount: order.paymentAmount ?? 0.0,
      date: DateTime.now(),
      orderId: order.id,
      createdDate: DateTime.now().toIso8601String(),
      updatedDate: DateTime.now().toIso8601String(),
    );

    await addInvoice(invoice);
  }
}
