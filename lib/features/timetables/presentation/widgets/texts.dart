import 'package:material_ui/material_ui.dart';

Widget roomText(BuildContext context, String room, bool special) {
  if (!room.contains("?") & !special) {
    return Text(room);
  }

  final parts = room.split("?");

  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: parts[0],
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (parts.length > 1) ...[
          const TextSpan(text: " "),
          TextSpan(
            text: parts[1],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ],
    ),
  );
}

Widget teacherText(String teacher, bool special) {
  if (!teacher.contains("?") & !special) {
    return Text(teacher);
  }

  final parts = teacher.split("?");

  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: parts[0],
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        if (parts.length > 1) ...[
          const TextSpan(text: " "),
          TextSpan(text: parts[1]),
        ],
      ],
    ),
  );
}

Widget classText(BuildContext context, List<String> classNames, bool collapse) {
  final classes = [...classNames];

  if (!collapse) {
    return Text(
      classes.join(', '),
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  final result = <String>[];
  final groups = <String, List<String>>{};

  for (final className in classes) {
    final match = RegExp(r'^(\d+)([a-zA-Z])$').firstMatch(className);

    if (match == null) {
      result.add(className);
      continue;
    }

    final prefix = match.group(1)!;
    groups.putIfAbsent(prefix, () => []).add(className);
  }

  for (final group in groups.values) {
    group.sort();

    if (group.length >= 2) {
      result.add('${group.first}-${group.last}');
    } else {
      result.add(group.first);
    }
  }

  return Text(result.join(', '), style: Theme.of(context).textTheme.titleLarge);
}
