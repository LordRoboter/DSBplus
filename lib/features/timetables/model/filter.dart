import 'package:planner/core/model/weekday.dart';

import 'timetable.dart';

class TimetableFilter {
  final Set<String> classes;
  final LessonRange? lessons;
  final Set<String> teachers;
  final Set<String> subjects;
  final Set<Weekday> days;

  const TimetableFilter({
    this.classes = const {},
    this.lessons,
    this.teachers = const {},
    this.subjects = const {},
    this.days = const {},
  });

  bool get isEmpty =>
      classes.isEmpty &&
      lessons == null &&
      teachers.isEmpty &&
      subjects.isEmpty &&
      days.isEmpty;

  Map<String, dynamic> toJson() {
    return {
      "classes": classes.toList(),
      "lessons": lessons?.toJson(),
      "subjects": subjects.toList(),
      "teachers": teachers.toList(),
      "days": days.map((e) => e.index).toList(),
    };
  }

  factory TimetableFilter.fromJson(Map<String, dynamic> json) {
    return TimetableFilter(
      classes: Set<String>.from(json["classes"] ?? []),
      lessons: json["lessons"] != null
          ? LessonRange.fromJson(json["lessons"])
          : null,
      subjects: Set<String>.from(json["subjects"] ?? []),
      teachers: Set<String>.from(json["teachers"] ?? []),
      days: (json["days"] as List? ?? []).map((e) => Weekday.values[e]).toSet(),
    );
  }

  TimetableFilter copyWith({
    Set<String>? classes,
    LessonRange? lessons,
    Set<String>? subjects,
    Set<String>? teachers,
    Set<Weekday>? days,
  }) {
    return TimetableFilter(
      classes: classes ?? this.classes,
      lessons: lessons ?? this.lessons,
      subjects: subjects ?? this.subjects,
      teachers: teachers ?? this.teachers,
      days: days ?? this.days,
    );
  }
}
