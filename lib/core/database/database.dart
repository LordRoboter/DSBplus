import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planner/core/database/converter.dart';
import 'package:planner/core/database/timetable.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Timetables, ClassEntries, TimetableEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'substitution_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
