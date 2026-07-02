import 'package:intl/intl.dart';

String getRelativeDay(String dateString) {
  final formatter = DateFormat('dd.MM.yyyy');

  try {
    final date = formatter.parseStrict(dateString);

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
        return "($dateString)";
    }
  } catch (_) {
    // Invalid date format
    return "";
  }
}

bool isOutdated(String dateString) {
  final formatter = DateFormat('dd.MM.yyyy');

  try {
    final date = formatter.parseStrict(dateString);

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
