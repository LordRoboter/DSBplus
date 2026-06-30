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

List<Map<String, dynamic>> cleanupEntries(List<Map<String, dynamic>> entries) {
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

    if (subject.endsWith('_')) {
      subject = subject.substring(0, subject.length - 1);
    }

    entry["subject"] = subject;
    entry["subject"] =
        subjectMap[entry["subject"].toString().toLowerCase()] ??
        entry["subject"];
  }

  return entries;
}
