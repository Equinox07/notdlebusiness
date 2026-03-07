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
    'SELECT IFNULL(SUM(amount), 0.0) FROM payments WHERE invoiceId = :invoiceId',
  )
  Future<double?> getTotalPaidForInvoice(String invoiceId);

  @Query(
    'SELECT IFNULL(SUM(amount), 0.0) FROM payments WHERE paymentDate >= :start AND paymentDate <= :end',
  )
  Future<double?> getIncomeBetween(int start, int end);

  @Query(
    'SELECT (SELECT IFNULL(SUM(totalQuotation), 0.0) FROM orders) - (SELECT IFNULL(SUM(amount), 0.0) FROM payments)',
  )
  Future<double?> getPendingPayments();

  @Query('SELECT IFNULL(SUM(amount), 0.0) FROM payments')
  Future<double?> getTotalRevenue();
}
