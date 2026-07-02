import 'package:flutter/material.dart';
import 'texts.dart';
import '../res/maps.dart';
import '../util/sorter.dart';

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
  final String classFilter;

  const EntryList({super.key, required this.groups, required this.classFilter});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: groups.entries.where((group) => group.value.isNotEmpty).map((
        group,
      ) {
        return EntryCard(
          group: group,
          marked: matchesClass(group.value.first, classFilter),
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

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${entry['lesson']}. Std${entry["subject"] != "---" ? " • ${entry["subject"]}" : ""}",
                              style: TextStyle(
                                fontWeight:
                                    ((entry["type"] == "Entfall") ||
                                        (entry["type"] ==
                                            "Eigenverantwortliches Arbeiten"))
                                    ? FontWeight.bold
                                    : FontWeight.bold,
                                decoration:
                                    ((entry["type"] == "Entfall") ||
                                        (entry["type"] ==
                                            "Eigenverantwortliches Arbeiten"))
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontStyle:
                                    ((entry["type"] == "Entfall") ||
                                        (entry["type"] ==
                                            "Eigenverantwortliches Arbeiten"))
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                            teacherText(entry["teacher"] ?? ""),

                            if ((entry["text"] ?? "").toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  entry["text"],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
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
                            label: Text(entry["type"] ?? ""),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: typeColor(entry["type"]),
                          ),
                          roomText(entry["room"].toString()),
                        ],
                      ),
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
