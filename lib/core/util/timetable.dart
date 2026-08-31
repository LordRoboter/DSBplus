import 'package:planner/features/timetables/model/daydate.dart';
import 'package:planner/features/timetables/model/timetable.dart';
import 'package:planner/core/util/date.dart';

List<DayDate> availableDayDates(List<Timetable> timetables) {
  return timetables.map(formatDayDate).toSet().toList();
}

bool isSpecialRoom(TimetableStatusType? type) {
  return switch (type) {
    TimetableStatusType.cancelled ||
    TimetableStatusType.roomSubstitution ||
    TimetableStatusType.event => true,
    _ => false,
  };
}

bool isSpecialTeacher(TimetableStatusType? type) {
  return switch (type) {
    TimetableStatusType.cancelled ||
    TimetableStatusType.substitution ||
    TimetableStatusType.supervision ||
    TimetableStatusType.despiteAbsence => true,
    _ => false,
  };
}
