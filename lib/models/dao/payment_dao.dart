import 'package:floor/floor.dart';
import 'package:notdle/models/payment.dart';

@dao
abstract class PaymentDao {
  @Query('SELECT * FROM payments')
  Future<List<Payment>> getAllPayments();

  @Query('SELECT * FROM payments WHERE id = :id')
  Future<Payment?> getPaymentById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPayment(Payment payment);

  @update
  Future<void> updatePayment(Payment payment);

  @delete
  Future<void> deletePayment(Payment payment);

  @Query('SELECT * FROM payments WHERE invoiceId = :invoiceId')
  Future<List<Payment>> getPaymentsForInvoice(String invoiceId);

  @Query(
    'SELECT SUM(amount) FROM payments WHERE date >= :start AND date <= :end',
  )
  Future<double?> getIncomeBetween(String start, String end);

  @Query(
    'SELECT (SELECT SUM(totalQuotation) FROM orders) - (SELECT SUM(amount) FROM payments)',
  )
  Future<double?> getPendingPayments();
}
