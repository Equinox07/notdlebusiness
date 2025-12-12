import 'package:floor/floor.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/invoice_item.dart'; // Import InvoiceItem
import 'package:notdle/models/payment.dart'; // Import Payment

@dao
abstract class InvoiceDao {
  // Invoice methods
  @Query('SELECT * FROM invoices')
  Future<List<Invoice>> getAllInvoices();

  @Query('SELECT * FROM invoices WHERE id = :id')
  Future<Invoice?> getInvoiceById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertInvoice(Invoice invoice);

  @update
  Future<void> updateInvoice(Invoice invoice);

  @delete
  Future<void> deleteInvoice(Invoice invoice);

  // InvoiceItem methods
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertInvoiceItem(InvoiceItem invoiceItem);

  @update
  Future<void> updateInvoiceItem(InvoiceItem invoiceItem);

  @Query('SELECT * FROM invoice_items WHERE invoiceId = :invoiceId')
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId);

  @Query('DELETE FROM invoice_items WHERE invoiceId = :invoiceId')
  Future<void> deleteInvoiceItems(String invoiceId);

  // Payment methods
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPayment(Payment payment);

  @update
  Future<void> updatePayment(Payment payment);

  @Query('SELECT * FROM payments WHERE invoiceId = :invoiceId')
  Future<List<Payment>> getPayments(String invoiceId);

  @Query('DELETE FROM payments WHERE invoiceId = :invoiceId')
  Future<void> deletePayments(String invoiceId);
}
