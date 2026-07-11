import 'package:intl/intl.dart';

class DateTimeFormatter {

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return "";

    return DateFormat("h:mm a").format(dateTime);
  }

  /// Today, Yesterday, Monday, or 12 Jul 2026
  static String formatChatDate(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = today.difference(date).inDays;

    if (difference == 0) {
      return "Today";
    }

    if (difference == 1) {
      return "Yesterday";
    }

    if (difference < 7) {
      return DateFormat("EEEE").format(dateTime);
    }

    return DateFormat("dd MMM yyyy").format(dateTime);
  }


  /// Home Screen
  /// Today -> 8:30 PM
  /// Yesterday -> Yesterday
  /// Within 7 days -> Mon
  /// Older -> 12/07/26
  static String formatLastMessageTime(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = today.difference(date).inDays;

    if (difference == 0) {
      return DateFormat("h:mm a").format(dateTime);
    }

    if (difference == 1) {
      return "Yesterday";
    }

    if (difference < 7) {
      return DateFormat("EEE").format(dateTime);
    }

    return DateFormat("dd/MM/yy").format(dateTime);
  }

  static String formatSeen(DateTime? dateTime) {
    if (dateTime == null) return "";

    return "Seen ${DateFormat("h:mm a").format(dateTime)}";
  }


  static String formatOnline(DateTime? dateTime) {
    if (dateTime == null) return "";

    return "Online ${DateFormat("h:mm a").format(dateTime)}";
  }
}