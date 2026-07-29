import 'package:intl/intl.dart';

String getRelativeDay(DateTime date) {
  try {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(todayDate).inDays;

    switch (difference) {
      case -1:
        return "(Gestern)";
      case 0:
        return "(Heute)";
      case 1:
        return "(Morgen)";
      default:
        return "(${DateFormat.yMd().format(date)})";
    }
  } catch (_) {
    // Invalid date format
    return "";
  }
}

bool isOutdated(DateTime date) {
  try {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(todayDate).inDays;

    if (difference < -1) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

String formatDayDate(Map<String, dynamic> entry) {
  final day = entry["day"] as String? ?? "Unknown";
  final date = entry["date"];

  final formattedDate = date is DateTime
      ? DateFormat.yMd().format(date)
      : "Unknown";

  return "$day ($formattedDate)";
}
