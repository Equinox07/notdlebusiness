import 'package:flutter/material.dart';
import 'package:notdle/models/dao/payment_dao.dart';
import 'package:notdle/models/financial_overview_stats.dart';

class FinancialProvider extends ChangeNotifier {
  final PaymentDao paymentDao;

  FinancialProvider({required this.paymentDao});

  Future<FinancialOverviewStats> getFinancialOverview() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final todayEnd = now.toIso8601String();

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final todaysIncome =
        await paymentDao.getIncomeBetween(todayStart, todayEnd) ?? 0.0;
    final thisWeekIncome =
        await paymentDao.getIncomeBetween(
          startOfWeek.toIso8601String(),
          endOfWeek.toIso8601String(),
        ) ??
        0.0;
    final thisMonthIncome =
        await paymentDao.getIncomeBetween(
          startOfMonth.toIso8601String(),
          endOfMonth.toIso8601String(),
        ) ??
        0.0;
    final pendingPayments = await paymentDao.getPendingPayments() ?? 0.0;

    return FinancialOverviewStats(
      todaysIncome: todaysIncome,
      thisWeekIncome: thisWeekIncome,
      thisMonthIncome: thisMonthIncome,
      pendingPayments: pendingPayments,
    );
  }
}
