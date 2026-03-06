class MoneyUtils {
  static int toCents(double amount) {
    return (amount * 100).round();
  }

  static double fromCents(int cents) {
    return cents / 100.0;
  }
}
