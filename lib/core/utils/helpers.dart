import 'package:intl/intl.dart';

class Helpers {
  static String formatScore(int score) {
    return NumberFormat('#,###').format(score);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String daysUntilExpiry(DateTime expiryDate) {
    final diff = expiryDate.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays == 0) return 'Expires today!';
    if (diff.inDays == 1) return 'Expires tomorrow';
    return 'Expires in ${diff.inDays} days';
  }

  static String formatTimer(int seconds) {
    return seconds.toString().padLeft(2, '0');
  }

  static bool isExpired(DateTime expiryDate) {
    return DateTime.now().isAfter(expiryDate);
  }
}
