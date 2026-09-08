import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/timetables/model/timetable.dart';

class LessonRangeConverter extends TypeConverter<LessonRange, String> {
  const LessonRangeConverter();

  @override
  LessonRange fromSql(String fromDb) {
    return LessonRange.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(LessonRange value) {
    return jsonEncode(value.toJson());
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();

  @override
  Map<String, String> fromSql(String fromDb) =>
      Map<String, String>.from(jsonDecode(fromDb));

  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

class WeekdayConverter extends TypeConverter<Weekday, String> {
  const WeekdayConverter();

  @override
  Weekday fromSql(String fromDb) => Weekday.values.byName(fromDb);

  @override
  String toSql(Weekday value) => value.name;
}

class TimetableStatusTypeConverter
    extends TypeConverter<TimetableStatusType, String> {
  const TimetableStatusTypeConverter();

  @override
  TimetableStatusType fromSql(String fromDb) =>
      TimetableStatusType.values.byName(fromDb);

  @override
  String toSql(TimetableStatusType value) => value.name;
}
