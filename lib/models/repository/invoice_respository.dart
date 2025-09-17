import 'package:notdle/models/dao/invoice_dao.dart';
import 'package:notdle/models/invoice.dart';

class InvoiceRepository {
  final InvoiceDao invoiceDao;

  InvoiceRepository({required this.invoiceDao});

  Future<List<Invoice>> getAllInvoices() {
    return invoiceDao.getAllInvoices();
  }

  // Future<List<Invoice>> getInvoicesForCustomer(String customerId) {
  //   return invoiceDao.getInvoicesForCustomer(customerId);
  // }

  Future<void> insertInvoice(Invoice invoice) {
    return invoiceDao.insertInvoice(invoice);
  }

  Future<void> updateInvoice(Invoice invoice) {
    return invoiceDao.updateInvoice(invoice);
  }

  Future<void> deleteInvoice(Invoice invoice) {
    return invoiceDao.deleteInvoice(invoice);
  }
}
