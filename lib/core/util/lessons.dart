import 'package:planner/core/models/timetable.dart';

LessonRange? parseLesson(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final cleaned = value.replaceAll(RegExp(r'[^\d,\-]'), '').trim();

  final rangeMatch = RegExp(r'^(\d+)\s*-\s*(\d+)$').firstMatch(cleaned);

  if (rangeMatch != null) {
    final start = int.parse(rangeMatch.group(1)!);
    final end = int.parse(rangeMatch.group(2)!);

    return LessonRange.range(start, end);
  }

  if (cleaned.contains(",")) {
    final lessons = cleaned
        .split(",")
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();

    return lessons.isEmpty ? null : LessonRange(lessons);
  }

  final lesson = int.tryParse(cleaned);

  return lesson != null ? LessonRange.single(lesson) : null;
}

Weekday? parseWeekday(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final cleaned = value.trim();

  switch (cleaned.toLowerCase()) {
    case "montag":
      return Weekday.monday;
    case "dienstag":
      return Weekday.tuesday;
    case "mittwoch":
      return Weekday.wednesday;
    case "donnerstag":
      return Weekday.thursday;
    case "freitag":
      return Weekday.friday;
    case "samstag":
      return Weekday.saturday;
    case "sonntag":
      return Weekday.sunday;
    default:
      return null;
  }
}
