import 'package:intl/intl.dart';

class Money {
  final int _cents; // Store amount in cents

  // Constructor accepts amount in cents (integer representation)
  Money(this._cents);

  // Get the total amount as double (for display purposes)
  double get amount => _cents / 100.0;

  // Returns a string formatted as currency (e.g., $10.50 or €10,50)
  String format(double d, {String? locale, String? currencyCode, required String symbol}) {
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );
    return format.format(amount);
  }

  // Add another Money value
  Money operator +(Money other) {
    return Money(_cents + other._cents);
  }

  // Subtract another Money value
  Money operator -(Money other) {
    return Money(_cents - other._cents);
  }

  // Compare two Money objects for equality (used to check if two values are the same)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Money && other._cents == _cents;
  }

  // Hash code for the Money object
  @override
  int get hashCode => _cents.hashCode;

  // Converts a double value into Money (cents)
  static Money fromDouble(double amount) {
    return Money((amount * 100).round());
  }

  // Returns the amount in cents (internal representation)
  int get cents => _cents;

  // Converts from cents back to Money
  static Money fromCents(int cents) {
    return Money(cents);
  }
}

extension MoneyFormatting on Money {
  String formatWithSymbol({
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );
    return format.format(amount);
  }
}
