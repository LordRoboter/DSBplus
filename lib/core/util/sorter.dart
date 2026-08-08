import 'package:planner/core/models/daydate.dart';
import 'package:planner/core/models/filter.dart';
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

Timetable decollapseTimetable(Timetable timetable) {
  final Map<String, ClassEntry> result = {};
  final List<String> order = [];

  for (final collapsedEntry in timetable.entries) {
    for (final className in collapsedEntry.classNames) {
      if (!result.containsKey(className)) {
        result[className] = ClassEntry(classNames: [className], entries: []);
        order.add(className);
      }

      result[className]!.entries.addAll(collapsedEntry.entries);
    }
  }

  return timetable.copyWith(
    entries: order.map((className) => result[className]!).toList(),
  );
}

bool isDigit(String c) {
  return c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
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
  for (final c in timetable.entries) {
    if (c.className.startsWith("E")) {
      print(
        '${c.classNames} -> ${c.entries.map((e) => '${e.subject} ${e.lesson} ${e.teacher}').join(", ")}',
      );
    }
  }
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

  final merged = <String, ClassEntry>{};

  for (final classEntry in cleanedClasses) {
    final key = classNamesKey(classEntry.classNames);

    if (merged.containsKey(key)) {
      merged[key] = ClassEntry(
        classNames: merged[key]!.classNames,
        entries: [...merged[key]!.entries, ...classEntry.entries],
      );
    } else {
      merged[key] = ClassEntry(
        classNames: classEntry.classNames.toSet().toList(),
        entries: classEntry.entries,
      );
    }
  }

  final resultEntries = merged.values.map((entry) {
    return ClassEntry(
      classNames: entry.classNames,
      entries: entry.entries.toSet().toList(),
    );
  }).toList();

  return Timetable(
    date: timetable.date,
    day: timetable.day,
    updated: timetable.updated,
    extraInfos: timetable.extraInfos,
    entries: resultEntries,
  );
}

String classNamesKey(List<String> classNames) {
  final normalized = classNames.map((c) => c.toLowerCase()).toSet().toList();

  normalized.sort();

  return normalized.join(",");
}

List<Timetable> filterTimetables(
  List<Timetable> timetables,
  List<TimetableFilter> filters,
) {
  if (filters.isEmpty) return timetables;

  final result = <Timetable>[];

  for (final timetable in timetables) {
    final filteredClasses = <ClassEntry>[];

    for (final classEntry in timetable.entries) {
      if (classEntry.classNames.any((c) => c.toLowerCase() == "alle")) {
        filteredClasses.add(classEntry);
        continue;
      }

      final matchingEntries = classEntry.entries
          .where(
            (entry) => filters.any(
              (filter) => matchesFilter(entry, classEntry, timetable, filter),
            ),
          )
          .toList();

      if (matchingEntries.isNotEmpty) {
        filteredClasses.add(classEntry.copyWith(entries: matchingEntries));
      }
    }

    if (filteredClasses.isNotEmpty) {
      result.add(timetable.copyWith(entries: filteredClasses));
    }
  }

  return result;
}

bool matchesFilter(
  TimetableEntry entry,
  ClassEntry classEntry,
  Timetable timetable,
  TimetableFilter filter,
) {
  if (filter.isEmpty) return true;

  if (filter.classes.isNotEmpty && !matchesClass(classEntry, filter)) {
    return false;
  }

  if (filter.lessons != null && entry.lesson != null) {
    if (!filter.lessons!.overlaps(entry.lesson!)) {
      return false;
    }
  } else if (filter.lessons != null && entry.lesson == null) {
    return false;
  }

  if (filter.subjects.isNotEmpty &&
      !filter.subjects.any(
        (s) => entry.subject?.toLowerCase().contains(s.toLowerCase()) ?? false,
      )) {
    return false;
  }

  if (filter.teachers.isNotEmpty &&
      !filter.teachers.any(
        (t) => entry.teacher?.toLowerCase().contains(t.toLowerCase()) ?? false,
      )) {
    return false;
  }

  if (filter.days.isNotEmpty && !filter.days.contains(timetable.day)) {
    return false;
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

bool matchesClass(ClassEntry entry, TimetableFilter filter) {
  final expanded = entry.classNames.expand((e) => {e.toLowerCase()});
  if (expanded.contains("alle")) {
    return true;
  }

  if (filter.classes.isEmpty) return false;

  final entryClasses = expanded
      .where((c) => c.isNotEmpty)
      .map(classBase)
      .toSet();

  return entryClasses.any(
    (ec) => filter.classes.any(
      (t) =>
          ec == classBase(t) ||
          ec.startsWith(classBase(t)) ||
          classBase(t).startsWith(ec),
    ),
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

  if (!simplify) {
    res = decollapseTimetable(res);
  }

  //groupedByDay[entry.key] = groupEntries(res);

  return res;
}

ClassDiff diffByClass(
  Timetable? oldTimetable,
  Timetable? newTimetable,
  Set<String> classes,
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
  return [
    e.day?.index ?? -1,
    e.entry.lesson?.lessons.toList()?..sort(),
    e.className,
  ].join("|");
}

bool isModified(_ClassedEntry oldE, _ClassedEntry newE) {
  return oldE.entry.subject != newE.entry.subject ||
      oldE.entry.teacher != newE.entry.teacher ||
      oldE.entry.room != newE.entry.room ||
      oldE.entry.type != newE.entry.type;
}

List<_ClassedEntry> _flattenEntries(Timetable? timetable, Set<String> classes) {
  if (timetable == null) return [];

  return timetable.entries
      .where(
        (classEntry) =>
            classes.isEmpty ||
            classes.any((c) => classEntry.classNames.contains(c)),
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
  final Weekday? day;
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
