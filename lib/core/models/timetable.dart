class Timetable {
  DateTime? date;
  String? day;
  DateTime? updated;
  Map<String, String>? extraInfos;
  final List<ClassEntry> entries;

  Timetable({
    this.date,
    this.day,
    this.updated,
    this.extraInfos,
    required this.entries,
  });
}

class ClassEntry {
  final String? className;
  final List<TimetableEntry> entries;

  const ClassEntry({this.className, required this.entries});
}

class TimetableEntry {
  final String? lesson;
  final String? teacher;
  final String? subject;
  final String? room;
  final String? type;
  final String? text;

  const TimetableEntry({
    this.lesson,
    this.teacher,
    this.subject,
    this.room,
    this.type,
    this.text,
  });
}
