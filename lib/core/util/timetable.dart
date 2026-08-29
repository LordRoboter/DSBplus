import 'package:planner/core/model/daydate.dart';
import 'package:planner/core/model/timetable.dart';
import 'package:planner/core/util/date.dart';

List<DayDate> availableDayDates(List<Timetable> timetables) {
  return timetables.map(formatDayDate).toSet().toList();
}
