import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/dsb/timetables/model/daydate.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:planner/core/util/translations.dart';

int getRelativeDay(DateTime date) {
  try {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(todayDate).inDays;

    return difference;
  } catch (_) {
    //TODO: Make this return more informative
    return 3;
  }
}

String getDayName(DateTime? date, Weekday? day, BuildContext context) {
  if (date == null) {
    return '';
  }

  final diff = getRelativeDay(date);

  if (-1 <= diff && diff <= 1) {
    return localizedRelativeWeekday(diff, context);
    // ${day != null ? ' (${localizedWeekday(context, day)})' : ''}
  }

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final targetDate = DateTime(date.year, date.month, date.day);
  final startOfThisWeek = todayDate.subtract(
    Duration(days: todayDate.weekday - 1),
  );
  final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
  if (!targetDate.isBefore(startOfThisWeek) &&
      !targetDate.isAfter(endOfThisWeek)) {
    return localizedWeekday(context, Weekday.values[targetDate.weekday - 1]);
  }
  return '${localizedWeekday(context, Weekday.values[targetDate.weekday - 1])} (${DateFormat.Md(Localizations.localeOf(context).toString()).format(date)})';
}

String getRelativeDayString(
  DateTime date,
  BuildContext context, {
  String? timePattern,
}) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context).toString();

  final diff = getRelativeDay(date);

  String dayString;

  if (-1 <= diff && diff <= 1) {
    dayString = localizedRelativeWeekday(diff, context);
  } else if (_isSameWeek(date, now)) {
    final weekday = DateFormat.EEEE(locale).format(date);
    final day = DateFormat.yMd(locale).format(date);
    dayString = '$weekday ($day)';
  } else {
    dayString = DateFormat.yMd(locale).format(date);
  }

  if (timePattern != null) {
    dayString += ' ${DateFormat(timePattern, locale).format(date)}';
  }

  return dayString;
}

bool _isSameWeek(DateTime a, DateTime b) {
  final aDate = DateTime(a.year, a.month, a.day);
  final bDate = DateTime(b.year, b.month, b.day);

  final aMonday = aDate.subtract(Duration(days: aDate.weekday - 1));
  final bMonday = bDate.subtract(Duration(days: bDate.weekday - 1));

  return aMonday == bMonday;
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

List<DayDate> computeAvailableDayDates(List<Timetable> timetables) {
  return timetables.map((e) => formatDayDate(e)).toSet().toList();
}
