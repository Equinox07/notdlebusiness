class InvoiceHelper {
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(
      2,
    ); // Get last two digits of the year
    final month = now.month.toString().padLeft(
      2,
      '0',
    ); // Ensure month is two digits
    final day = now.day.toString().padLeft(2, '0'); // Ensure day is two digits
    final randomDigits = (now.microsecondsSinceEpoch % 10000)
        .toString()
        .padLeft(
          4,
          '0',
        ); // Generate a random 4-digit number based on current time

    return 'INV$year$month$day$randomDigits';
  }
}
  