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

List<Map<String, dynamic>> cleanupEntries(List<Map<String, dynamic>> entries) {
  for (final entry in entries) {
    entry["class"] = (entry["class"] as String).split("_")[0].split(" ")[0];
  }

  return entries;
}
