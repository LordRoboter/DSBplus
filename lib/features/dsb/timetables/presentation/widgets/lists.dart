import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/util/timetable.dart';
import 'package:planner/features/dsb/timetables/model/filter.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:planner/features/settings/model/settings_state.dart';
import 'package:planner/core/util/translations.dart';
import '../../../../../l10n/l10extension.dart';
import 'texts.dart';
import '../../../../../core/res/maps.dart';
import '../../../../../core/util/sorter.dart';

class EntryListNoScroll extends StatelessWidget {
  final Timetable timetable;
  final SettingsState settings;

  const EntryListNoScroll({
    super.key,
    required this.timetable,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: timetable.entries
          .map(
            (entry) =>
                EntryCard(entry: entry, settings: settings, marked: false),
          )
          .toList(),
    );
  }
}

class EntryList extends StatelessWidget {
  final Timetable timetable;
  final SettingsState settings;
  final List<TimetableFilter> filters;
  final TimetableFilter classFilter;

  const EntryList({
    super.key,
    required this.timetable,
    required this.settings,
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
          settings: settings,
          entry: classEntry,
          marked: groupMarked,
          filters: filters,
          classFilter: classFilter,
        );
      }).toList(),
    );
  }
}

class EntryCard extends ConsumerWidget {
  final Timetable? timetable;
  final SettingsState settings;
  final ClassEntry entry;
  final bool marked;
  final List<TimetableFilter>? filters;
  final TimetableFilter? classFilter;

  const EntryCard({
    super.key,
    this.timetable,
    required this.settings,
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
  Widget build(BuildContext context, WidgetRef ref) {
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
            classText(context, entry.classNames, settings.collapse),

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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${ordinal(lesson.lesson, Localizations.localeOf(context))} ${context.l10n.lsn}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isSpecial
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontStyle: isSpecial
                                      ? FontStyle.italic
                                      : null,
                                ),
                              ),

                              if (lesson.subject != null &&
                                  lesson.subject != "---") ...[
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Flexible(
                                  child: lessonText(lesson.subject!, isSpecial),
                                ),
                              ],
                            ],
                          ),

                          teacherText(
                            lesson.teacher ?? "",
                            isSpecialTeacher(lesson.type),
                          ),

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
                              context.l10n,
                              lesson.type,
                              original: !settings.remapTypes && isGerman,
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: typeColor(lesson.type),
                        ),

                        roomText(
                          context,
                          lesson.room ?? "",
                          isSpecialRoom(lesson.type),
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
