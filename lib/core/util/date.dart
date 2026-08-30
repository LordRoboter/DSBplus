import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/model/daydate.dart';
import 'package:planner/core/model/timetable.dart';
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
    return "${localizedRelativeWeekday(diff, context)}";
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
  return '${localizedWeekday(context, Weekday.values[targetDate.weekday - 1])} (${DateFormat.Md(Localizations.localeOf(context).toString()).format(date)});
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
