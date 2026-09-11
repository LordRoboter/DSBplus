import 'package:planner/core/database/database.dart';

class TimetableSyncResult {
  final List<Timetable> previous;
  final List<Timetable> current;

  const TimetableSyncResult({required this.previous, required this.current});
}
