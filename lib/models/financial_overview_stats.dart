import 'package:intl/intl.dart';

class FinancialOverviewStats {
  final double todaysIncome;
  final double thisWeekIncome;
  final double thisMonthIncome;
  final double pendingPayments;

  FinancialOverviewStats({
    this.todaysIncome = 0.0,
    this.thisWeekIncome = 0.0,
    this.thisMonthIncome = 0.0,
    this.pendingPayments = 0.0,
  });
}

extension FinancialOverviewStatsExtension on FinancialOverviewStats {
  /// Convert today's income to cents
  int get todaysIncomeCents => (todaysIncome * 100).round();

  /// Convert week income to cents
  int get thisWeekIncomeCents => (thisWeekIncome * 100).round();

  /// Convert month income to cents
  int get thisMonthIncomeCents => (thisMonthIncome * 100).round();

  /// Convert pending payments to cents
  int get pendingPaymentsCents => (pendingPayments * 100).round();

  /// Format today's income
  String formatTodaysIncome({
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );

    return formatter.format(todaysIncome);
  }

  /// Format weekly income
  String formatWeekIncome({
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );

    return formatter.format(thisWeekIncome);
  }

  /// Format monthly income
  String formatMonthIncome({
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );

    return formatter.format(thisMonthIncome);
  }

  /// Format pending payments
  String formatPendingPayments({
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );

    return formatter.format(pendingPayments);
  }

  /// Generic currency formatter
  String formatCurrency(
    double value, {
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol:
          currencyCode == 'GHS'
              ? '₵'
              : currencyCode, // Use symbol for GHS, otherwise default
      name: currencyCode,
    );

    return formatter.format(value);
  }

  /// Total income across all tracked periods
  double get totalTrackedIncome =>
      todaysIncome + thisWeekIncome + thisMonthIncome;
}
