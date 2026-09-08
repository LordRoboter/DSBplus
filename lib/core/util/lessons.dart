import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/timetables/model/timetable.dart';

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

TimetableStatusType? parseStatus(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final cleaned = value.trim().toLowerCase();

  switch (cleaned) {
    // No class
    case "entfall":
    case "eigenverantwortliches arbeiten":
      return TimetableStatusType.cancelled;

    // Different teacher
    case "vertretung":
      return TimetableStatusType.substitution;

    // Different lesson (1/2 -> 5/6)
    case "unterricht geändert":
      return TimetableStatusType.classChanged;

    // Relevant for teachers?
    case "sondereinsatz":
    case "sondereins.":
      return TimetableStatusType.specialAssignment;

    // Different room
    case "raum-vertretung":
    case "raum-vtr.":
      return TimetableStatusType.roomSubstitution;

    // Different room (special event)
    case "veranstaltung":
    case "veranst.":
      return TimetableStatusType.event;

    // No teacher
    case "trotz absenz":
    case "trotzabsenz":
      return TimetableStatusType.despiteAbsence;

    // Different subject?
    case "statt-vertretung":
      return TimetableStatusType.substituteLesson;

    // Different teacher
    case "betreuung":
      return TimetableStatusType.supervision;

    case "verlegung":
      return TimetableStatusType.rescheduling;

    default:
      return null;
  }
}
