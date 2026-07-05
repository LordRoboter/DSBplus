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

    if (!grouped.containsKey(key)) {
      grouped[key] = {
        ...entry,
        '_classes': <String>{entry['class']},
      };
    } else {
      (grouped[key]!['_classes'] as Set<String>).add(entry['class']);
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
  bool cleanClassNames = true,
  bool remapTypes = true,
  bool disposeCourseNumbers = true,
}) {
  for (final entry in entries) {
    var classs = entry["class"] as String;
    classs = classs.split("_")[0].split(" ")[0];
    classs = classs.replaceFirst(RegExp(r'^0+'), '');
    entry["class"] = classs;

    entry["type"] =
        typeMap[entry["type"].toString().toLowerCase()] ?? entry["type"];

    final String subj = entry["subject"] as String;

    if (subj.length > 2 &&
        (subj[0] == 'E' || subj[0] == 'Q') &&
        isDigit(subj[1])) {
      entry["subject"] = subj.substring(2);
    }

    var subject = entry["subject"] as String;

    subject = subject
        .replaceFirst(RegExp(r'^\d+'), '')
        .replaceFirst(RegExp(r'\d.*$'), '');

    String suffix = "";

    if (subject.contains("_")) {
      final index = subject.lastIndexOf("_");
      suffix = subject.substring(index);
      subject = subject.substring(0, index);
    }

    subject = subjectMap[subject.toLowerCase()] ?? subject;

    entry["subject"] = subject + suffix;
  }

  return entries;
}

List<Map<String, dynamic>> filterByClass(
  List<Map<String, dynamic>> entries,
  String classes,
) {
  final terms = classes
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .toSet();

  if (terms.isEmpty) return entries;

  return entries.where((entry) {
    final entryClasses = (entry["class"] as String? ?? "")
        .toLowerCase()
        .split(RegExp(r'\s*,\s*'))
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty);

    if (entryClasses.contains("alle")) return true;

    return entryClasses.any(terms.contains);
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

bool matchesClass(Map<String, dynamic> entry, String query) {
  if (entry["class"].toString().toLowerCase() == "alle") return true;

  final terms = query
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .toList();

  if (terms.isEmpty) return false;

  final searchable = [
    entry["class"],
  ].where((e) => e != null).join(" ").toLowerCase();

  return terms.any((term) => searchable.contains(term));
}

Map<String, Map<String, List<Map<String, dynamic>>>> sortEntries(
  List<Map<String, dynamic>> entries,
  bool clean,
  bool simplify,
) {
  final dayResult = groupEntriesByDay(entries);

  final groupedByDay = <String, Map<String, List<Map<String, dynamic>>>>{};

  for (final entry in dayResult.entries) {
    var res = entry.value;

    if (clean) {
      res = cleanupEntries(res);
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
