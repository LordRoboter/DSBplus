import 'package:flutter/material.dart';

Widget roomText(BuildContext context, String room) {
  if (!room.contains("?")) {
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
        const TextSpan(text: " "),
        TextSpan(
          text: parts[1],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget teacherText(String room) {
  if (!room.contains("?")) {
    return Text(room);
  }

  final parts = room.split("?");

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
        const TextSpan(text: " "),
        TextSpan(text: parts[1]),
      ],
    ),
  );
}
