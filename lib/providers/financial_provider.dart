import 'package:flutter/material.dart';
import 'package:notdle/models/dao/payment_dao.dart';
import 'package:notdle/models/financial_overview_stats.dart';

class FinancialProvider extends ChangeNotifier {
  final PaymentDao paymentDao;

  FinancialProvider({required this.paymentDao});

  Future<FinancialOverviewStats> getFinancialOverview() async {
    try {
      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final todayEnd = now.millisecondsSinceEpoch;

      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final todaysIncome =
          await paymentDao.getIncomeBetween(todayStart, todayEnd) ?? 0.0;
      debugPrint('Todays Income: $todaysIncome');

      final thisWeekIncome =
          await paymentDao.getIncomeBetween(
            startOfWeek.millisecondsSinceEpoch,
            endOfWeek.millisecondsSinceEpoch,
          ) ??
          0.0;
      debugPrint('This Week Income: $thisWeekIncome');

      final thisMonthIncome =
          await paymentDao.getIncomeBetween(
            startOfMonth.millisecondsSinceEpoch,
            endOfMonth.millisecondsSinceEpoch,
          ) ??
          0.0;
      debugPrint('This Month Income: $thisMonthIncome');

      final pendingPayments = await paymentDao.getPendingPayments() ?? 0.0;
      debugPrint('Pending Payments: $pendingPayments');

      return FinancialOverviewStats(
        todaysIncome: todaysIncome,
        thisWeekIncome: thisWeekIncome,
        thisMonthIncome: thisMonthIncome,
        pendingPayments: pendingPayments,
      );
    } catch (e, s) {
      debugPrint('Error loading financial overview: $e');
      debugPrint('Stack trace: $s');
      rethrow;
    }
  }

  Future<double> getTotalRevenue() async {
    return await paymentDao.getTotalRevenue() ?? 0.0;
  }

  void refresh() {
    notifyListeners();
  }
}
