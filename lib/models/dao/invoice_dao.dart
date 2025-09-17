import 'package:floor/floor.dart';
import 'package:notdle/models/invoice.dart';

@dao
abstract class InvoiceDao {
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
}
