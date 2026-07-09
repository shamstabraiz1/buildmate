import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs. ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String compactCurrency(double amount) {
    if (amount >= 10000000) return 'Rs. ${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return 'Rs. ${(amount / 100000).toStringAsFixed(2)} L';
    return currency(amount);
  }

  static String date(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy · hh:mm a').format(date);
  }
}
