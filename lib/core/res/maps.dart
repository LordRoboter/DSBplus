import 'package:material_ui/material_ui.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';

Color typeColor(TimetableStatusType? type) {
  switch (type) {
    case TimetableStatusType.cancelled:
      return Colors.red.shade100;

    case TimetableStatusType.substitution:
      return Colors.orange.shade100;

    case TimetableStatusType.classChanged:
      return Colors.purple.shade100;

    case TimetableStatusType.specialAssignment:
      return Colors.blue.shade50;

    case TimetableStatusType.roomSubstitution:
      return Colors.orange.shade50;

    case TimetableStatusType.event:
      return Colors.green.shade100;

    case TimetableStatusType.despiteAbsence:
      return Colors.yellow.shade100;

    case TimetableStatusType.substituteLesson:
      return Colors.amber.shade100;

    case TimetableStatusType.supervision:
      return Colors.orangeAccent.shade100;

    case TimetableStatusType.rescheduling:
      return Colors.indigo.shade200;

    default:
      return Colors.grey.shade200;
  }
}
