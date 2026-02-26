import 'package:flutter/material.dart';
import 'package:notdle/models/dao/payment_dao.dart';
import 'package:notdle/models/payment.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/services/session_manager.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentDao paymentDao;

  PaymentProvider({required this.paymentDao});

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  Future<void> fetchPayments() async {
    _payments = await paymentDao.getAllPayments();
    notifyListeners();
  }

  Future<void> fetchPaymentsForInvoice(String invoiceId) async {
    _payments = await paymentDao.getPaymentsForInvoice(invoiceId);
    notifyListeners();
  }

  Future<void> addPayment(Payment payment) async {
    final company = await SessionManager.getCompany();
    final user = await ApiService().getStoredUser();

    final updatedPayment = payment.copyWith(
      companyId: company?.id,
      userId: user?.id,
    );

    await paymentDao.insertPayment(updatedPayment);
    await fetchPaymentsForInvoice(payment.invoiceId);
  }

  Future<void> updatePayment(Payment payment) async {
    await paymentDao.updatePayment(payment);
    await fetchPaymentsForInvoice(payment.invoiceId);
  }

  Future<void> deletePayment(Payment payment) async {
    await paymentDao.deletePayment(payment);
    await fetchPaymentsForInvoice(payment.invoiceId);
  }
}
