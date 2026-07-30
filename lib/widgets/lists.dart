import 'package:flutter/material.dart';
import 'texts.dart';
import '../res/maps.dart';
import '../core/util/sorter.dart';

class EntryListNoScroll extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> groups;

  const EntryListNoScroll({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: groups.entries
          .where((group) => group.value.isNotEmpty)
          .map((group) => EntryCard(group: group, marked: false))
          .toList(),
    );
  }
}

class EntryList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> groups;
  final List<Map<String, String>> filters;
  final String classFilter;

  const EntryList({
    super.key,
    required this.groups,
    required this.filters,
    required this.classFilter,
  });

  @override
  Widget build(BuildContext context) {
    bool matchesAnyFilter(Map<String, dynamic> entry) {
      return filters.any((filter) => matchesFilter(entry, filter));
    }

    return ListView(
      children: groups.entries.where((group) => group.value.isNotEmpty).map((
        group,
      ) {
        final groupMarked =
            classFilter.isNotEmpty &&
            group.value.any((entry) => matchesClass(entry, classFilter));

        final entries = group.value.map((entry) {
          final entryMarked =
              (classFilter.isNotEmpty &&
                  matchesClass(entry, classFilter) &&
                  matchesAnyFilter(entry)) ||
              (classFilter.isEmpty && matchesAnyFilter(entry));

          return {...entry, 'marked': entryMarked};
        }).toList();

        return EntryCard(
          group: MapEntry(group.key, entries),
          marked: groupMarked,
        );
      }).toList(),
    );
  }
}

class EntryCard extends StatelessWidget {
  final MapEntry<String, List<Map<String, dynamic>>> group;
  final bool marked;

  const EntryCard({super.key, required this.group, required this.marked});

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
            Text(group.key, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),

            ...group.value.asMap().entries.map((item) {
              final entry = item.value;
              final entryMarked = entry['marked'] == true;

              final isSpecial =
                  entry["type"] == "Entfall" ||
                  entry["type"] == "Eigenverantwortliches Arbeiten";

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                decoration: entryMarked
                    ? BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${entry['lesson']}. Std"
                                "${entry["subject"] != "---" ? " • ${entry["subject"]}" : ""}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isSpecial
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontStyle: isSpecial
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),

                              teacherText(entry["teacher"] ?? ""),

                              if ((entry["text"] ?? "").toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Text(
                                    entry["text"],
                                    style: TextStyle(
                                      color: entryMarked
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer
                                          : Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                      fontWeight: entryMarked
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Chip(
                              label: Text(
                                entry["type"] ?? "",
                                style: TextStyle(
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                            typeColor(entry["type"]),
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: entryMarked
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: typeColor(entry["type"]),
                            ),

                            roomText(context, entry["room"].toString()),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
