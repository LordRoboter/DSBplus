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

  Map<String, dynamic> toJson() {
    return {
      "date": date?.millisecondsSinceEpoch,
      "updated": updated?.millisecondsSinceEpoch,
      "day": day,
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
      day: json["day"],
      extraInfos: Map<String, String>.from(json["extraInfos"] ?? {}),
      entries: (json["entries"] as List)
          .map((e) => ClassEntry.fromJson(e))
          .toList(),
    );
  }

  Timetable copyWith({
    DateTime? date,
    String? day,
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

  Map<String, dynamic> toJson() {
    return {
      "lesson": lesson,
      "teacher": teacher,
      "subject": subject,
      "room": room,
      "type": type,
      "text": text,
    };
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      lesson: json["lesson"],
      teacher: json["teacher"],
      subject: json["subject"],
      room: json["room"],
      type: json["type"],
      text: json["text"],
    );
  }

  TimetableEntry copyWith({
    String? lesson,
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
