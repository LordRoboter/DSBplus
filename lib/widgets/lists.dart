import 'package:flutter/material.dart';
import 'package:planner/core/models/filter.dart';
import 'package:planner/core/models/timetable.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/services/data_repository.dart';
import 'package:provider/provider.dart';
import '../l10n/l10extension.dart';
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
  final List<TimetableFilter> filters;
  final TimetableFilter classFilter;

  const EntryList({
    super.key,
    required this.timetable,
    required this.filters,
    required this.classFilter,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: timetable.entries.map((classEntry) {
        final groupMarked = matchesClass(classEntry, classFilter);

        return EntryCard(
          timetable: timetable,
          entry: classEntry,
          marked: groupMarked,
          filters: filters,
          classFilter: classFilter,
        );
      }).toList(),
    );
  }
}

class EntryCard extends StatelessWidget {
  final Timetable? timetable;
  final ClassEntry entry;
  final bool marked;
  final List<TimetableFilter>? filters;
  final TimetableFilter? classFilter;

  const EntryCard({
    super.key,
    this.timetable,
    required this.entry,
    required this.marked,
    this.filters,
    this.classFilter,
  });

  bool matchesAnyFilter(
    TimetableEntry entry,
    ClassEntry classEntry,
    Timetable timetable,
    List<TimetableFilter> filters,
    TimetableFilter classFilter,
  ) {
    if (filters.isEmpty) return false;

    return filters.any(
      (filter) =>
          (classFilter.classes.isEmpty ||
              matchesClass(classEntry, classFilter)) &&
          matchesFilter(entry, classEntry, timetable, filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataRepository>();
    final isGerman = Localizations.localeOf(context).languageCode == 'de';
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

            Divider(
              color: marked
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).dividerColor,
            ),

            ...entry.entries.map((lesson) {
              final isSpecial = lesson.type == TimetableStatusType.cancelled;

              final entryMarked =
                  (timetable != null && filters != null && classFilter != null)
                  ? matchesAnyFilter(
                      lesson,
                      entry,
                      timetable!,
                      filters!,
                      classFilter!,
                    )
                  : false;

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${ordinal(lesson.lesson, Localizations.localeOf(context))} ${context.l10n.lsn}"
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
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Chip(
                          label: Text(
                            localizedStatus(
                              context,
                              lesson.type,
                              original: !data.remapTypes && isGerman,
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: typeColor(lesson.type),
                        ),

                        roomText(context, lesson.room ?? ""),
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
