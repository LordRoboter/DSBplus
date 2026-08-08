import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/widgets/lists.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/core/util/date.dart';
import 'package:provider/provider.dart';

import '../services/plan_repository.dart';
import '../core/util/sorter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /*final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<PlanRepository>();
      if (repo.loading) {
        _refreshKey.currentState?.show();
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PlanRepository>();
    final data = context.watch<DataRepository>();

    final classResults = filterTimetables(repo.entries, [data.classFilter]);

    final filteredResults = filterTimetables(classResults, data.filters);

    final finalResults = data.filters.isNotEmpty
        ? filteredResults
        : classResults;

    /*if (repo.loading && _refreshKey.currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshKey.currentState?.show();
      });
    }*/

    final enhancedTimetables = finalResults
        .map(
          (timetable) => enhanceTimetable(
            context,
            timetable,
            data.clean,
            data.simplify,
            disposeTut: data.disposeTut,
            cleanClassNames: data.cleanClassNames,
            remapTypes: data.remapTypes,
            cleanupCourses: data.cleanupCourses,
            disposeCourseNumbers: data.disposeCourseNumbers,
            mapCourses: data.mapCourses,
          ),
        )
        .toList();
    return RefreshIndicator(
      //key: _refreshKey,
      onRefresh: () async {
        await repo.loadData();
      },

      child: enhancedTimetables.isEmpty && repo.loading
          ? const Center(child: CircularProgressIndicator())
          : enhancedTimetables.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(child: Text(context.l10n.noRelevantEntries)),
                  ),
                );
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: enhancedTimetables.length,
              separatorBuilder: (_, _) => const SizedBox(height: 48),
              itemBuilder: (context, index) {
                final dayTimetable = enhancedTimetables.elementAt(index);
                final relativeDay = dayTimetable.date != null
                    ? getRelativeDay(dayTimetable.date!)
                    : null;
                final date = dayTimetable.date;
                final formattedDate = date != null
                    ? "(${DateFormat.yMd(Localizations.localeOf(context).toString()).format(date)})"
                    : "";
                final dayName = switch (relativeDay) {
                  0 => context.l10n.today,
                  1 => context.l10n.tomorrow,
                  -1 => context.l10n.yesterday,
                  _ =>
                    "${localizedWeekday(context, dayTimetable.day)} $formattedDate",
                };

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dayName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                            if (isOutdated(dayTimetable.date!))
                              Tooltip(
                                message: context.l10n.outdatedEntry,
                                child: IconButton(
                                  icon: const Icon(Icons.warning_amber_rounded),
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () {},
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: EntryListNoScroll(timetable: dayTimetable),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
