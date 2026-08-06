enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class LessonRange {
  final Set<int> lessons;

  const LessonRange(this.lessons);

  factory LessonRange.single(int lesson) => LessonRange({lesson});

  factory LessonRange.range(int start, int end) =>
      LessonRange({for (var i = start; i <= end; i++) i});

  bool contains(int lesson) => lessons.contains(lesson);

  Map<String, dynamic> toJson() => {"lessons": lessons.toList()..sort()};

  factory LessonRange.fromJson(Map<String, dynamic> json) =>
      LessonRange(Set<int>.from(json["lessons"]));

  @override
  String toString() {
    if (lessons.isEmpty) return "";

    final sorted = lessons.toList()..sort();
    final ranges = <String>[];
    var start = sorted.first;
    var end = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == end + 1) {
        end = sorted[i];
      } else {
        ranges.add(start == end ? "$start" : "$start-$end");
        start = sorted[i];
        end = sorted[i];
      }
    }

    ranges.add(start == end ? "$start" : "$start-$end");
    return ranges.join(",");
  }
}

extension LessonRangeExtension on LessonRange {
  bool overlaps(LessonRange other) {
    return lessons.intersection(other.lessons).isNotEmpty;
  }
}

class Timetable {
  DateTime? date;
  Weekday? day;
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

  Map<String, dynamic> toJson() {
    return {
      "date": date?.millisecondsSinceEpoch,
      "updated": updated?.millisecondsSinceEpoch,
      "day": day?.index,
      "extraInfos": extraInfos,
      "entries": entries.map((e) => e.toJson()).toList(),
    };
  }

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      date: json["date"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["date"])
          : null,
      updated: json["updated"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["updated"])
          : null,
      day: json["day"] != null ? Weekday.values[json["day"]] : null,
      extraInfos: Map<String, String>.from(json["extraInfos"] ?? {}),
      entries: (json["entries"] as List)
          .map((e) => ClassEntry.fromJson(e))
          .toList(),
    );
  }

  Timetable copyWith({
    DateTime? date,
    Weekday? day,
    DateTime? updated,
    Map<String, String>? extraInfos,
    List<ClassEntry>? entries,
  }) {
    return Timetable(
      date: date ?? this.date,
      day: day ?? this.day,
      updated: updated ?? this.updated,
      extraInfos: extraInfos ?? this.extraInfos,
      entries: entries ?? this.entries,
    );
  }
}

class ClassEntry {
  List<String> classNames;
  final List<TimetableEntry> entries;

  ClassEntry({required this.classNames, required this.entries});

  Map<String, dynamic> toJson() {
    return {
      "classNames": classNames,
      "entries": entries.map((e) => e.toJson()).toList(),
    };
  }

  factory ClassEntry.fromJson(Map<String, dynamic> json) {
    return ClassEntry(
      classNames: (json["classNames"] as List).cast<String>(),
      entries: (json["entries"] as List)
          .map((e) => TimetableEntry.fromJson(e))
          .toList(),
    );
  }

  ClassEntry copyWith({
    List<String>? classNames,
    List<TimetableEntry>? entries,
  }) {
    return ClassEntry(
      classNames: classNames ?? this.classNames,
      entries: entries ?? this.entries,
    );
  }

  String get className => classNames.join(", ");
}

class TimetableEntry {
  final LessonRange? lesson;
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

  Map<String, dynamic> toJson() {
    return {
      "lesson": lesson?.toJson(),
      "teacher": teacher,
      "subject": subject,
      "room": room,
      "type": type,
      "text": text,
    };
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      lesson: json["lesson"] != null
          ? LessonRange.fromJson(json["lesson"])
          : null,
      teacher: json["teacher"],
      subject: json["subject"],
      room: json["room"],
      type: json["type"],
      text: json["text"],
    );
  }

  TimetableEntry copyWith({
    LessonRange? lesson,
    String? teacher,
    String? subject,
    String? room,
    String? type,
    String? text,
  }) {
    return TimetableEntry(
      lesson: lesson ?? this.lesson,
      teacher: teacher ?? this.teacher,
      subject: subject ?? this.subject,
      room: room ?? this.room,
      type: type ?? this.type,
      text: text ?? this.text,
    );
  }
}
