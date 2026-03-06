import 'package:flutter/material.dart';
import 'package:notdle/models/dao/invoice_dao.dart';
import 'package:notdle/utils/helpers.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/order.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/services/session_manager.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceDao invoiceDao;

  InvoiceProvider({required this.invoiceDao});

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  Future<void> fetchInvoices() async {
    final rawInvoices = await invoiceDao.getAllInvoices();
    final List<Invoice> loadedInvoices = [];
    for (final invoice in rawInvoices) {
      final items = await invoiceDao.getInvoiceItems(invoice.id);
      loadedInvoices.add(invoice.copyWith(items: items));
    }
    _invoices = loadedInvoices;
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    final company = await SessionManager.getCompany();
    final user = await ApiService().getStoredUser();

    final updatedInvoice = invoice.copyWith(
      companyId: company?.id,
      userId: user?.id,
    );

    await invoiceDao.insertInvoice(updatedInvoice);
    for (final item in updatedInvoice.items) {
      final updatedItem = item.copyWith(
        companyId: company?.id,
        userId: user?.id,
      );
      await invoiceDao.insertInvoiceItem(updatedItem);
    }
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
    final company = await SessionManager.getCompany();
    final user = await ApiService().getStoredUser();

    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: generateInvoiceNumber(),
      customerId: order.customerId,
      companyId: company?.id,
      userId: user?.id,
      status: 'unpaid',
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      createdDate: DateTime.now().toIso8601String(),
      updatedDate: DateTime.now().toIso8601String(),
    );

    await addInvoice(invoice);
  }
}
