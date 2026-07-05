import '../res/maps.dart';

Map<String, List<Map<String, dynamic>>> groupEntries(
  List<Map<String, dynamic>> entries,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};

  for (final entry in entries) {
    final className = entry["class"] as String? ?? "Unknown";

    grouped.putIfAbsent(className, () => []);

    grouped[className]!.add(entry);
  }

  return grouped;
}

Map<String, List<Map<String, dynamic>>> groupEntriesByDay(
  List<Map<String, dynamic>> entries,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};

  for (final entry in entries) {
    final day = entry["day"] as String? ?? "Unknown";

    grouped.putIfAbsent(day, () => []);
    grouped[day]!.add(entry);
  }

  return grouped;
}

Map<String, List<Map<String, dynamic>>> groupEntriesByAllowedDays(
  List<Map<String, dynamic>> entries,
  List<String> allowedDays,
) {
  // Start with all allowed days as empty lists
  final grouped = <String, List<Map<String, dynamic>>>{
    for (final day in allowedDays) day: [],
  };

  for (final entry in entries) {
    final day = entry["day"] as String?;

    // Only accept entries whose day is in the allowed list
    if (day != null && grouped.containsKey(day)) {
      grouped[day]!.add(entry);
    }
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

List<Map<String, dynamic>> cleanupEntries(
  List<Map<String, dynamic>> entries, {
  bool disposeTut = true,
  bool cleanClassNames = true,
  bool remapTypes = true,
  bool cleanupCourses = true,
  bool disposeCourseNumbers = true,
  bool mapCourses = true,
}) {
  return entries.map((entry) {
    // Create a copy so the original cache is never modified.
    final cleaned = Map<String, dynamic>.from(entry);

    // ----- Class -----
    var classs = cleaned["class"] as String;
    classs = classs.split(" ")[0];

    if (disposeTut) {
      classs = classs.split("_")[0];
    }

    if (cleanClassNames) {
      classs = classs.replaceFirst(RegExp(r'^0+'), '');
    }

    cleaned["class"] = classs;

    // ----- Type -----
    if (remapTypes) {
      cleaned["type"] =
          typeMap[cleaned["type"].toString().toLowerCase()] ?? cleaned["type"];
    }

    // ----- Subject -----
    var subject = cleaned["subject"] as String;

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

    cleaned["subject"] = subject + suffix;

    return cleaned;
  }).toList();
}

List<Map<String, dynamic>> filterByClass(
  List<Map<String, dynamic>> entries,
  String classes,
) {
  final terms = classes
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .map(classBase)
      .toSet();

  if (terms.isEmpty) return entries;

  return entries.where((entry) {
    final raw = (entry["class"] as String? ?? "").toLowerCase();

    final entryClasses = raw
        .split(RegExp(r'\s*,\s*|\s+'))
        .where((c) => c.isNotEmpty)
        .map(classBase)
        .toSet();

    if (entryClasses.contains("alle")) return true;

    return entryClasses.any(
      (ec) => terms.any((t) => ec == t || ec.startsWith(t)),
    );
  }).toList();
}

bool matches(Map<String, dynamic> entry, String query) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .toList();

  if (terms.isEmpty) return true;

  final searchable = [
    entry["subject"],
    entry["teacher"],
    entry["type"],
    entry["text"],
    entry["class"],
  ].where((e) => e != null).join(" ").toLowerCase();

  return terms.every((term) => searchable.contains(term));
}

String normalizeClass(String c) {
  c = c.toLowerCase().trim();

  // remove leading zeros in numbers: 07a -> 7a
  c = c.replaceFirstMapped(RegExp(r'\b0+(\d)'), (m) => '${m[1]}');

  return c;
}

String classBase(String c) {
  c = normalizeClass(c);

  // strip trailing zeros (e.g. "7a0" -> "7a", "70" -> "7")
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

Map<String, Map<String, List<Map<String, dynamic>>>> sortEntries(
  List<Map<String, dynamic>> entries,
  bool clean,
  bool simplify, {
  bool disposeTut = true,
  bool cleanClassNames = true,
  bool remapTypes = true,
  bool cleanupCourses = true,
  bool disposeCourseNumbers = true,
  bool mapCourses = true,
}) {
  final dayResult = groupEntriesByDay(entries);

  final groupedByDay = <String, Map<String, List<Map<String, dynamic>>>>{};

  for (final entry in dayResult.entries) {
    var res = entry.value;

    if (clean) {
      res = cleanupEntries(
        res,
        disposeTut: disposeTut,
        cleanClassNames: cleanClassNames,
        remapTypes: remapTypes,
        cleanupCourses: cleanupCourses,
        disposeCourseNumbers: disposeCourseNumbers,
        mapCourses: mapCourses,
      );
    }

    if (simplify) {
      res = simplifyEntries(res);
    }

    groupedByDay[entry.key] = groupEntries(res);
  }

  return groupedByDay;
}

ClassDiff diffByClass(
  List<Map<String, dynamic>> oldEntries,
  List<Map<String, dynamic>> newEntries,
  String classes,
) {
  final oldFiltered = filterByClass(oldEntries, classes);
  final newFiltered = filterByClass(newEntries, classes);

  final oldMap = {for (var e in oldFiltered) entryKey(e): e};
  final newMap = {for (var e in newFiltered) entryKey(e): e};

  final added = <Map<String, dynamic>>[];
  final removed = <Map<String, dynamic>>[];
  final modified = <Map<String, dynamic>>[];

  for (final key in oldMap.keys) {
    if (!newMap.containsKey(key)) {
      removed.add(oldMap[key]!);
    } else {
      final oldE = oldMap[key]!;
      final newE = newMap[key]!;

      if (isModified(oldE, newE)) {
        modified.add(newE);
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

String entryKey(Map<String, dynamic> e) {
  return [e["day"] ?? "", e["lesson"] ?? "", e["class"] ?? ""].join("|");
}

bool isModified(Map<String, dynamic> oldE, Map<String, dynamic> newE) {
  return oldE["subject"] != newE["subject"] ||
      oldE["teacher"] != newE["teacher"] ||
      oldE["room"] != newE["room"] ||
      oldE["type"] != newE["type"];
}

class ClassDiff {
  final List<Map<String, dynamic>> added;
  final List<Map<String, dynamic>> removed;

  bool get hasChanges => added.isNotEmpty || removed.isNotEmpty;

  ClassDiff({required this.added, required this.removed});
}
