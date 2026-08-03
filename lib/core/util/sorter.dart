import 'package:planner/core/models/daydate.dart';
import 'package:planner/core/models/timetable.dart';
import 'package:planner/core/util/date.dart';

import '../../res/maps.dart';

Map<DayDate, Timetable> groupEntriesByDayDate(List<Timetable> timetables) {
  final grouped = <DayDate, Timetable>{};

  for (final timetable in timetables) {
    final dayDate = DayDate(timetable.day, timetable.date);

    grouped[dayDate] = timetable;
  }

  return grouped;
}

List<Map<String, dynamic>> simplifyEntries(List<Map<String, dynamic>> entries) {
  final grouped = <String, Map<String, dynamic>>{};

  for (final entry in entries) {
    final key = [
      entry['type'],
      entry['lesson'],
      entry['subject'],
      entry['room'],
      entry['new_subject'],
      entry['new_teacher'],
      entry['teacher'],
      entry["day"],
      entry["date"],
    ].join('|');

    final classList = (entry['class'] as String? ?? '')
        .split(RegExp(r'\s*,\s*'))
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toSet();

    if (!grouped.containsKey(key)) {
      grouped[key] = {...entry, '_classes': classList};
    } else {
      (grouped[key]!['_classes'] as Set<String>).addAll(classList);
    }
  }

  return grouped.values.map((entry) {
    final classes = (entry.remove('_classes') as Set<String>).toList()..sort();
    entry['class'] = classes.join(', ');
    return entry;
  }).toList();
}

bool isDigit(String c) {
  return c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

({int start, int end})? parseLessonRange(String value) {
  final matches = RegExp(r'\d+').allMatches(value).toList();

  if (matches.isEmpty) return null;

  final start = int.tryParse(matches.first.group(0)!);
  final end = int.tryParse(
    matches.length > 1 ? matches.last.group(0)! : matches.first.group(0)!,
  );

  if (start == null || end == null) return null;

  return (start: start, end: end);
}

bool lessonRangesOverlap(String entryValue, String filterValue) {
  final entryRange = parseLessonRange(entryValue);
  final filterRange = parseLessonRange(filterValue);

  if (entryRange == null || filterRange == null) return false;

  return entryRange.start <= filterRange.end &&
      filterRange.start <= entryRange.end;
}

Timetable cleanupTimetable(
  Timetable timetable, {
  bool disposeTut = true,
  bool cleanClassNames = true,
  bool remapTypes = true,
  bool cleanupCourses = true,
  bool disposeCourseNumbers = true,
  bool mapCourses = true,
}) {
  final cleanedClasses = timetable.entries.map((classEntry) {
    final cleanedClassNames = classEntry.classNames.map((className) {
      var cleaned = className;

      if (disposeTut) {
        cleaned = cleaned.split("_")[0];
      }

      if (cleanClassNames) {
        cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
      }

      return cleaned;
    }).toList();

    final cleanedEntries = classEntry.entries.map((entry) {
      var subject = entry.subject ?? "";
      var type = entry.type ?? "";

      // ----- Type -----
      if (remapTypes) {
        type = typeMap[type.toLowerCase()] ?? type;
      }

      // ----- Subject -----
      if (cleanupCourses) {
        subject = subject
            .replaceFirst(RegExp(r'[EQ]\d'), '')
            .replaceFirst(RegExp(r'^\d+'), '')
            .replaceFirst(RegExp(r'\d+\D$'), '');
      }

      if (disposeCourseNumbers) {
        subject = subject.replaceFirst(RegExp(r'\d+$'), '');
      }

      String suffix = "";

      if (mapCourses) {
        final match = RegExp(r'(_.*|\d+)$').firstMatch(subject);

        if (match != null) {
          suffix = match.group(0)!;
          subject = subject.substring(0, match.start);
        }

        subject = subjectMap[subject.toLowerCase()] ?? subject;
      }

      return TimetableEntry(
        lesson: entry.lesson,
        teacher: entry.teacher,
        room: entry.room,
        text: entry.text,
        subject: subject + suffix,
        type: type,
      );
    }).toList();

    return ClassEntry(classNames: cleanedClassNames, entries: cleanedEntries);
  }).toList();

  return Timetable(
    date: timetable.date,
    day: timetable.day,
    updated: timetable.updated,
    extraInfos: timetable.extraInfos,
    entries: cleanedClasses,
  );
}

List<Timetable> filterByClass(List<Timetable> timetables, String classes) {
  final terms = classes
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .map(classBase)
      .toSet();

  if (terms.isEmpty) return timetables;

  return timetables.where((timetable) {
    final hasUnknownClass = timetable.entries.any(
      (e) => e.className == null || e.className!.isEmpty,
    );

    if (hasUnknownClass) return true;

    final entryClasses = timetable.entries
        .map((e) => e.className!)
        .expand((c) => c.split(RegExp(r'\s*,\s*|\s+')))
        .where((c) => c.isNotEmpty)
        .map(classBase)
        .toSet();

    if (entryClasses.contains("alle")) return true;

    return entryClasses.any(
      (ec) => terms.any((t) => ec == t || ec.startsWith(t)),
    );
  }).toList();
}

List<Timetable> filterByInfo(
  List<Timetable> timetables,
  Map<String, String> filters,
) {
  if (filters.isEmpty) return timetables;

  final result = <Timetable>[];

  for (final timetable in timetables) {
    final filteredClasses = <ClassEntry>[];

    for (final classEntry in timetable.entries) {
      if ((classEntry.className ?? "").toLowerCase() == "alle") {
        filteredClasses.add(classEntry);
        continue;
      }

      final matchingEntries = classEntry.entries.where((entry) {
        final entryClass = (classEntry.className ?? "").toLowerCase();
        final entryLesson = (entry.lesson ?? "").toLowerCase();
        final entrySubject = (entry.subject ?? "").toLowerCase();
        final entryTeacher = (entry.teacher ?? "").toLowerCase();
        final entryDay = (timetable.day ?? "").toLowerCase();

        for (final filter in filters.entries) {
          final value = filter.value.toLowerCase().trim();

          if (value.isEmpty) continue;

          switch (filter.key.toLowerCase()) {
            case "class":
              if (!entryClass.contains(value)) return false;
              break;

            case "lesson":
              if (!lessonRangesOverlap(entryLesson, value)) return false;
              break;

            case "subject":
              if (!entrySubject.contains(value)) return false;
              break;

            case "teacher":
              if (!entryTeacher.contains(value)) return false;
              break;

            case "day":
              if (!entryDay.contains(value)) return false;
              break;
          }
        }

        return true;
      }).toList();

      if (matchingEntries.isNotEmpty) {
        filteredClasses.add(classEntry.copyWith(entries: matchingEntries));
      }
    }

    final hasRealMatch = filteredClasses.any(
      (c) => (c.className ?? "").toLowerCase() != "alle",
    );

    if (hasRealMatch) {
      result.add(timetable.copyWith(entries: filteredClasses));
    }
  }

  return result;
}

bool matchesFilter(
  TimetableEntry entry,
  ClassEntry classEntry,
  Timetable timetable,
  Map<String, String> filters,
) {
  if (filters.isEmpty) return true;

  final lesson = (entry.lesson ?? "").toLowerCase();
  final subject = (entry.subject ?? "").toLowerCase();
  final teacher = (entry.teacher ?? "").toLowerCase();
  final day = (timetable.day ?? "").toLowerCase();

  for (final filter in filters.entries) {
    final key = filter.key.toLowerCase();
    final value = filter.value.trim().toLowerCase();

    if (value.isEmpty) continue;

    switch (key) {
      case "class":
        if (!classEntry.classNames.any(
          (c) => c.toLowerCase().contains(value),
        )) {
          return false;
        }
        break;

      case "lesson":
        if (!lessonRangesOverlap(lesson, value)) {
          return false;
        }
        break;

      case "subject":
        if (!subject.contains(value)) {
          return false;
        }
        break;

      case "teacher":
        if (!teacher.contains(value)) {
          return false;
        }
        break;

      case "day":
        if (!day.contains(value)) {
          return false;
        }
        break;

      default:
        return false;
    }
  }

  return true;
}

bool matches(ClassEntry classEntry, TimetableEntry entry, String query) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .toList();

  if (terms.isEmpty) return true;

  final searchable = [
    classEntry.className,
    entry.subject,
    entry.teacher,
    entry.type,
    entry.text,
    entry.room,
    entry.lesson,
  ].whereType<String>().join(' ').toLowerCase();

  return terms.every((term) => searchable.contains(term));
}

String normalizeClass(String c) {
  c = c.toLowerCase().trim();

  c = c.replaceFirstMapped(RegExp(r'\b0+(\d)'), (m) => '${m[1]}');

  return c;
}

String classBase(String c) {
  c = normalizeClass(c);

  c = c.replaceFirst(RegExp(r'0+$'), '');

  return c;
}

bool matchesClass(Map<String, dynamic> entry, String query) {
  if ((entry["class"] ?? "").toString().toLowerCase() == "alle") {
    return true;
  }

  final terms = query
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .map(classBase)
      .toSet();

  if (terms.isEmpty) return false;

  final entryClasses = (entry["class"] as String? ?? "")
      .toLowerCase()
      .split(RegExp(r'\s*,\s*|\s+'))
      .where((c) => c.isNotEmpty)
      .map(classBase)
      .toSet();

  return entryClasses.any(
    (ec) => terms.any((t) => ec == t || ec.startsWith(t) || t.startsWith(ec)),
  );
}

Timetable enhanceTimetable(
  Timetable timetable,
  bool clean,
  bool simplify, {
  bool disposeTut = true,
  bool cleanClassNames = true,
  bool remapTypes = true,
  bool cleanupCourses = true,
  bool disposeCourseNumbers = true,
  bool mapCourses = true,
}) {
  var res = timetable;

  if (clean) {
    res = cleanupTimetable(
      res,
      disposeTut: disposeTut,
      cleanClassNames: cleanClassNames,
      remapTypes: remapTypes,
      cleanupCourses: cleanupCourses,
      disposeCourseNumbers: disposeCourseNumbers,
      mapCourses: mapCourses,
    );
  }

  //if (!simplify) {
  //  res = deSimplifyEntries(res);
  //}

  //groupedByDay[entry.key] = groupEntries(res);

  return res;
}

ClassDiff diffByClass(
  Timetable? oldTimetable,
  Timetable? newTimetable,
  String classes,
) {
  final oldEntries = _flattenEntries(oldTimetable, classes);
  final newEntries = _flattenEntries(newTimetable, classes);

  final oldMap = {for (final e in oldEntries) entryKey(e): e};
  final newMap = {for (final e in newEntries) entryKey(e): e};

  final added = <_ClassedEntry>[];
  final removed = <_ClassedEntry>[];

  for (final key in oldMap.keys) {
    if (!newMap.containsKey(key)) {
      removed.add(oldMap[key]!);
    } else {
      final oldE = oldMap[key]!;
      final newE = newMap[key]!;

      if (isModified(oldE, newE)) {
        // optional: handle modified entries here
      }
    }
  }

  for (final key in newMap.keys) {
    if (!oldMap.containsKey(key)) {
      added.add(newMap[key]!);
    }
  }

  return ClassDiff(added: added, removed: removed);
}

String entryKey(_ClassedEntry e) {
  return [e.day ?? "", e.entry.lesson ?? "", e.className].join("|");
}

bool isModified(_ClassedEntry oldE, _ClassedEntry newE) {
  return oldE.entry.subject != newE.entry.subject ||
      oldE.entry.teacher != newE.entry.teacher ||
      oldE.entry.room != newE.entry.room ||
      oldE.entry.type != newE.entry.type;
}

List<_ClassedEntry> _flattenEntries(Timetable? timetable, String classes) {
  if (timetable == null) return [];

  return timetable.entries
      .where(
        (classEntry) =>
            classes.isEmpty || classEntry.classNames.contains(classes),
      )
      .expand(
        (classEntry) => classEntry.entries.map(
          (entry) => _ClassedEntry(
            className: classEntry.className,
            entry: entry,
            day: timetable.day,
          ),
        ),
      )
      .toList();
}

class _ClassedEntry {
  final String className;
  final String? day;
  final TimetableEntry entry;

  _ClassedEntry({
    required this.className,
    required this.entry,
    required this.day,
  });
}

class ClassDiff {
  final List<_ClassedEntry> added;
  final List<_ClassedEntry> removed;

  bool get hasChanges => added.isNotEmpty || removed.isNotEmpty;

  ClassDiff({required this.added, required this.removed});
}
