import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/widgets/lists.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/core/util/sorter.dart';
import 'package:planner/widgets/modals.dart';
import 'package:provider/provider.dart';

import '../services/plan_repository.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen>
    with SingleTickerProviderStateMixin {
  var isSearching = false;
  String search = "";

  late final AnimationController _rotationController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final repo = context.read<PlanRepository>();
    final data = context.read<DataRepository>();

    if (data.selectedDayDate == null && repo.availableDayDates.isNotEmpty) {
      data.setSelectedDayDate(repo.availableDayDates.first);
    }
  }

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PlanRepository>();
    final data = context.watch<DataRepository>();

    final locale = Localizations.localeOf(context).toString();

    if (repo.loading) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      if (_rotationController.isAnimating) {
        _rotationController.stop();
        _rotationController.reset();
      }
    }

    final enhancedTimetables = repo.entries
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
    final sortedEntries = groupEntriesByDayDate(enhancedTimetables);

    final visibleTimetable = data.selectedDayDate != null
        ? sortedEntries[data.selectedDayDate!]
        : null;

    final filteredTimetable = isSearching && visibleTimetable != null
        ? visibleTimetable.copyWith(
            entries: visibleTimetable.entries
                .map(
                  (classEntry) => classEntry.copyWith(
                    entries: classEntry.entries
                        .where((e) => matches(classEntry, e, search))
                        .toList(),
                  ),
                )
                .where((classEntry) => classEntry.entries.isNotEmpty)
                .toList(),
          )
        : visibleTimetable;

    return repo.error != null
        ? RefreshIndicator(
            onRefresh: () async {
              await repo.loadData();
            },
            child: Center(child: Text(repo.error!)),
          )
        : (filteredTimetable == null || filteredTimetable.entries.isEmpty) &&
              repo.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isSearching
                    ? Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              itemCount: repo.availableDayDates.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final dayDate = repo.availableDayDates[index];
                                final label = getDayName(
                                  dayDate.date,
                                  dayDate.day,
                                  context,
                                );
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: data.selectedDayDate == dayDate,
                                  onSelected: (_) {
                                    data.setSelectedDayDate(dayDate);
                                  },
                                );
                              },
                            ),
                          ),

                          SizedBox(
                            height: 36,
                            child: TextField(
                              key: const ValueKey('search'),
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: context.l10n.search,
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() => isSearching = false);
                                  },
                                ),
                                isDense: true,

                                contentPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  14,
                                  12,
                                  6,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  search = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            key: const ValueKey('chips'),
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: repo.availableDayDates.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final dayDate =
                                          repo.availableDayDates[index];
                                      final label = getDayName(
                                        dayDate.date,
                                        dayDate.day,
                                        context,
                                      );

                                      return ChoiceChip(
                                        label: Text(label),
                                        selected:
                                            data.selectedDayDate == dayDate,
                                        onSelected: (_) {
                                          data.setSelectedDayDate(dayDate);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                IconButton.filled(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {
                                    setState(() => isSearching = true);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: visibleTimetable == null
                                    ? null
                                    : () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          showDragHandle: true,
                                          builder: (_) {
                                            return PlanDetailsSheet(
                                              timetable: visibleTimetable,
                                            );
                                          },
                                        );
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        flex: 8,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: context.l10n.date,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          visibleTimetable
                                                                  ?.date !=
                                                              null
                                                          ? DateFormat.yMd(
                                                              locale,
                                                            ).format(
                                                              visibleTimetable!
                                                                  .date!,
                                                            )
                                                          : '',
                                                    ),
                                                  ],
                                                ),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Flexible(
                                        flex: 11,
                                        fit: FlexFit.loose,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: IconButton(
                                                iconSize: 18,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 18,
                                                      minHeight: 18,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                splashRadius: 18,
                                                onPressed: repo.loading
                                                    ? null
                                                    : () async {
                                                        await repo.loadData();
                                                      },
                                                icon: RotationTransition(
                                                  turns: _rotationController,
                                                  child: const Icon(
                                                    Icons.refresh,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          context.l10n.updated,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          visibleTimetable
                                                                  ?.updated !=
                                                              null
                                                          ? DateFormat.yMd(
                                                              locale,
                                                            ).add_Hm().format(
                                                              visibleTimetable!
                                                                  .updated!,
                                                            )
                                                          : '',
                                                    ),
                                                  ],
                                                ),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 4),

                                      const Icon(Icons.chevron_right, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await repo.loadData();
                  },
                  child:
                      filteredTimetable == null ||
                          filteredTimetable.entries.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: Text(context.l10n.noEntries),
                                ),
                              ),
                            );
                          },
                        )
                      : EntryList(
                          timetable: filteredTimetable,
                          filters: data.filters,
                          classFilter: data.classFilter,
                        ),
                ),
              ),
            ],
          );
  }
}
