import 'package:intl/intl.dart';
import 'package:planner/core/models/daydate.dart';
import 'package:planner/core/models/timetable.dart';

int getRelativeDay(DateTime date) {
  try {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(todayDate).inDays;

    return difference;
  } catch (_) {
    //TODO: Make this return more informative
    return 2;
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

DayDate formatDayDate(Timetable timetable) {
  final day = timetable.day;
  final date = timetable.date;

  return DayDate(day, date);
}
