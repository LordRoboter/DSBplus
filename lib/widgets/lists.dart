import 'package:flutter/material.dart';
import 'package:planner/core/models/timetable.dart';
import 'texts.dart';
import '../res/maps.dart';
import '../core/util/sorter.dart';

class EntryListNoScroll extends StatelessWidget {
  final Timetable timetable;

  const EntryListNoScroll({super.key, required this.timetable});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: timetable.entries
          .map((entry) => EntryCard(entry: entry, marked: false))
          .toList(),
    );
  }
}

class EntryList extends StatelessWidget {
  final Timetable timetable;
  final List<Map<String, String>> filters;
  final String classFilter;

  const EntryList({
    super.key,
    required this.timetable,
    required this.filters,
    required this.classFilter,
  });

  @override
  Widget build(BuildContext context) {
    bool matchesAnyFilter(
      TimetableEntry entry,
      ClassEntry classEntry,
      Timetable timetable,
      List<Map<String, String>> filters,
    ) {
      if (filters.isEmpty) return true;

      return filters.any(
        (filter) => matchesFilter(entry, classEntry, timetable, filter),
      );
    }

    return ListView(
      children: timetable.entries.map((classEntry) {
        final groupMarked =
            classFilter.isNotEmpty &&
            classEntry.classNames.contains(classFilter);

        return EntryCard(entry: classEntry, marked: groupMarked);
      }).toList(),
    );
  }
}

//TODO: Bring back singular marked entries
class EntryCard extends StatelessWidget {
  final ClassEntry entry;
  final bool marked;

  const EntryCard({super.key, required this.entry, required this.marked});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: marked
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.classNames.join(", "),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(),

            ...entry.entries.map((lesson) {
              final isSpecial =
                  lesson.type == "Entfall" ||
                  lesson.type == "Eigenverantwortliches Arbeiten";

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${lesson.lesson}. Std"
                          "${lesson.subject != "---" ? " • ${lesson.subject}" : ""}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isSpecial
                                ? TextDecoration.lineThrough
                                : null,
                            fontStyle: isSpecial ? FontStyle.italic : null,
                          ),
                        ),

                        teacherText(lesson.teacher ?? ""),

                        if ((lesson.text ?? "").isNotEmpty)
                          Text(
                            lesson.text!,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Chip(
                        label: Text(lesson.type ?? ""),
                        backgroundColor: typeColor(lesson.type ?? ""),
                      ),

                      roomText(context, lesson.room ?? ""),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
