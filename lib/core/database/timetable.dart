import 'package:drift/drift.dart';
import 'package:planner/core/database/converter.dart';

class Timetables extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime().nullable()();
  // Stored as String for possible type changes
  TextColumn get day => text().nullable().map(const WeekdayConverter())();

  DateTimeColumn get updated => dateTime().nullable()();
  DateTimeColumn get firstFetched => dateTime().nullable()();
  DateTimeColumn get lastFetched => dateTime().nullable()();

  // JSON encoded Map<String, String>
  TextColumn get extraInfos =>
      text().nullable().map(const StringMapConverter())();
}

class ClassEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get timetableId => integer().references(Timetables, #id)();

  // JSON encoded List<String>
  TextColumn get classNames => text().map(const StringListConverter())();
}

class TimetableEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get classEntryId => integer().references(ClassEntries, #id)();

  // JSON encoded LessonRange
  TextColumn get lesson =>
      text().nullable().map(const LessonRangeConverter())();

  TextColumn get teacher => text().nullable()();
  TextColumn get subject => text().nullable()();
  TextColumn get room => text().nullable()();

  // Stored as String for possible type changes
  TextColumn get type =>
      text().nullable().map(const TimetableStatusTypeConverter())();

  TextColumn get description => text().nullable()();
}
