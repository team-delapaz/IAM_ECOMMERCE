import 'package:intl/intl.dart';

/// Utility class for formatting text, dates, currency, and phone numbers.
class IAMFormatter {
  /// Formats a [DateTime] object into a readable string like '04-Nov-2025'.
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  /// Formats a numeric [amount] into Philippine Peso currency format.
  ///
  /// Example:
  /// ```dart
  /// TFormatter.formatCurrency(12345.67); // ₱12,345.67
  /// ```
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    return format.format(amount);
  }

  /// Plain amount for accounting-style rows (grouping + decimals, no currency symbol).
  static String formatAccountingAmount(double amount) {
    return NumberFormat('#,##0.00', 'en_PH').format(amount);
  }

  /// Formats a Philippine mobile phone number into a standard format.
  ///
  /// Supports the following patterns:
  /// - `09171234567` → `+63 917 123 4567`
  /// - `9171234567` → `+63 917 123 4567`
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Handle numbers starting with '0' (e.g., 0917 → +63 917)
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    // Ensure it starts with +63
    String formatted =
        '+63 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
    return formatted;
  }

  /// Formats an international number (generic version, defaults to +63 if local)
  ///
  /// Example:
  /// ```dart
  /// TFormatter.internationalFormatPhoneNumber('09171234567'); // +63 917 123 4567
  /// ```
  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Detect and normalize to +63 if local
    if (digitsOnly.startsWith('0')) {
      digitsOnly = '+63${digitsOnly.substring(1)}';
    } else if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    }

    // Clean up again just to be safe
    final cleaned = digitsOnly.replaceAll(RegExp(r'\D'), '');
    final countryCode = '+${cleaned.substring(0, 2)}';
    final rest = cleaned.substring(2);

    // Format like +63 917 123 4567
    final buffer = StringBuffer('$countryCode ');
    int i = 0;
    while (i < rest.length) {
      int groupLength = (i == 0)
          ? 3
          : (i == 3)
          ? 3
          : 4;
      int end = (i + groupLength > rest.length) ? rest.length : i + groupLength;
      buffer.write(rest.substring(i, end));
      if (end < rest.length) buffer.write(' ');
      i = end;
    }

    return buffer.toString();
  }
}
