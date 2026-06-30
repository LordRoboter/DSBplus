import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/plan_repository.dart';
import '../components/texts.dart';
import '../res/maps.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PlanRepository>();

    final visibleGroups = repo.groupedEntries[repo.selectedDay] ?? {};
    final visibleEntries = repo.entries[repo.selectedDay] ?? [];

    return repo.loading
        ? const Center(child: CircularProgressIndicator())
        : repo.error != null
        ? Center(child: Text(repo.error!))
        : repo.ggroup && repo.groupedEntries.isNotEmpty
        ? Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: repo.availableDays.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = repo.availableDays[index];

                    return ChoiceChip(
                      label: Text(day),
                      selected: repo.selectedDay == day,
                      onSelected: (_) => repo.selectDay(day),
                    );
                  },
                ),
              ),

              Expanded(
                child: ListView(
                  children: visibleGroups.entries.map((group) {
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.key,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Divider(),

                            ...group.value.asMap().entries.map((item) {
                              final entry = item.value;

                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${entry['lesson']}. Std${entry["subject"] != "---" ? " • " + entry["subject"] : ""}",
                                              style: TextStyle(
                                                fontWeight:
                                                    ((entry["type"] ==
                                                            "Entfall") ||
                                                        (entry["type"] ==
                                                            "Eigenverantwortliches Arbeiten"))
                                                    ? FontWeight.bold
                                                    : FontWeight.bold,
                                                decoration:
                                                    ((entry["type"] ==
                                                            "Entfall") ||
                                                        (entry["type"] ==
                                                            "Eigenverantwortliches Arbeiten"))
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                                fontStyle:
                                                    ((entry["type"] ==
                                                            "Entfall") ||
                                                        (entry["type"] ==
                                                            "Eigenverantwortliches Arbeiten"))
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                              ),
                                            ),
                                            teacherText(entry["teacher"] ?? ""),

                                            if ((entry["text"] ?? "")
                                                .toString()
                                                .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Chip(
                                            label: Text(entry["type"] ?? ""),
                                            visualDensity:
                                                VisualDensity.compact,
                                            backgroundColor: typeColor(
                                              entry["type"],
                                            ),
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
                  }).toList(),
                ),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: repo.availableDays.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = repo.availableDays[index];

                    return ChoiceChip(
                      label: Text(day),
                      selected: repo.selectedDay == day,
                      onSelected: (_) => repo.selectDay(day),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: visibleEntries.length,
                  itemBuilder: (context, index) {
                    final entry = visibleEntries[index];

                    return ListTile(
                      title: Text("${entry['lesson']} - ${entry['subject']}"),
                      subtitle: Text("${entry['class']} • ${entry['room']}"),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
