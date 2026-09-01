import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:planner/features/timetables/model/daydate.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/features/timetables/presentation/widgets/flexible_row.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/features/timetables/providers/enhanced_timetables_provider.dart';
import 'package:planner/features/timetables/providers/timetable_provider.dart';
import 'package:planner/features/timetables/presentation/widgets/lists.dart';
import 'package:planner/core/util/sorter.dart';
import 'package:planner/features/timetables/presentation/widgets/modals.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen>
    with SingleTickerProviderStateMixin {
  bool isSearching = false;
  String search = '';

  DayDate? selectedDayDate;

  late final AnimationController _rotationController;

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
    final timetables = ref.watch(enhancedTimetablesProvider);
    final settings = ref.watch(settingsProvider);
    final dayDates = ref.watch(availableDayDatesProvider);
    final isRefreshing = ref.watch(timetableRefreshingProvider);

    final locale = Localizations.localeOf(context).toString();

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settingsState) {
        return dayDates.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (availableDayDates) {
            final currentSelectedDayDate =
                selectedDayDate ??
                (availableDayDates.isNotEmpty ? availableDayDates.first : null);

            if (selectedDayDate == null && currentSelectedDayDate != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && selectedDayDate == null) {
                  setState(() {
                    selectedDayDate = currentSelectedDayDate;
                  });
                }
              });
            }

            return timetables.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              data: (enhancedTimetables) {
                if (isRefreshing) {
                  if (!_rotationController.isAnimating) {
                    _rotationController.repeat();
                  }
                } else {
                  if (_rotationController.isAnimating) {
                    _rotationController.stop();
                    _rotationController.reset();
                  }
                }

                final sortedEntries = groupEntriesByDayDate(enhancedTimetables);

                final visibleTimetable = currentSelectedDayDate != null
                    ? sortedEntries[currentSelectedDayDate]
                    : null;

                final filteredTimetable =
                    isSearching && visibleTimetable != null
                    ? visibleTimetable.copyWith(
                        entries: visibleTimetable.entries
                            .map(
                              (classEntry) => classEntry.copyWith(
                                entries: classEntry.entries
                                    .where(
                                      (e) => matches(classEntry, e, search),
                                    )
                                    .toList(),
                              ),
                            )
                            .where(
                              (classEntry) => classEntry.entries.isNotEmpty,
                            )
                            .toList(),
                      )
                    : visibleTimetable;

                return (filteredTimetable == null ||
                            filteredTimetable.entries.isEmpty) &&
                        isRefreshing
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
                                          itemCount: availableDayDates.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(width: 8),
                                          itemBuilder: (context, index) {
                                            final dayDate =
                                                availableDayDates[index];

                                            final label = getDayName(
                                              dayDate.date,
                                              dayDate.day,
                                              context,
                                            );

                                            return ChoiceChip(
                                              label: Text(label),
                                              selected:
                                                  currentSelectedDayDate ==
                                                  dayDate,
                                              onSelected: (_) {
                                                setState(() {
                                                  selectedDayDate = dayDate;
                                                });
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
                                            prefixIcon: const Icon(
                                              Icons.search,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  isSearching = false;
                                                  search = '';
                                                });
                                              },
                                            ),
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
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
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                itemCount:
                                                    availableDayDates.length,
                                                separatorBuilder: (_, _) =>
                                                    const SizedBox(width: 8),
                                                itemBuilder: (context, index) {
                                                  final dayDate =
                                                      availableDayDates[index];

                                                  final label = getDayName(
                                                    dayDate.date,
                                                    dayDate.day,
                                                    context,
                                                  );

                                                  return ChoiceChip(
                                                    label: Text(label),
                                                    selected:
                                                        currentSelectedDayDate ==
                                                        dayDate,
                                                    onSelected: (_) {
                                                      setState(() {
                                                        selectedDayDate =
                                                            dayDate;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            IconButton.filled(
                                              icon: const Icon(Icons.search),
                                              onPressed: () {
                                                setState(() {
                                                  isSearching = true;
                                                });
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            onTap: visibleTimetable == null
                                                ? null
                                                : () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      showDragHandle: true,
                                                      builder: (_) {
                                                        return PlanDetailsSheet(
                                                          timetable:
                                                              visibleTimetable,
                                                        );
                                                      },
                                                    );
                                                  },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                              child: PriorityRow(
                                                spacing: 8,
                                                trailingSpacing: 4,

                                                left: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                              text: context
                                                                  .l10n
                                                                  .date,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                right: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      height: 18,
                                                      width: 18,
                                                      child: IconButton(
                                                        iconSize: 18,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(
                                                              minWidth: 18,
                                                              minHeight: 18,
                                                            ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        splashRadius: 18,
                                                        onPressed: isRefreshing
                                                            ? null
                                                            : () async {
                                                                await ref
                                                                    .read(
                                                                      timetableProvider
                                                                          .notifier,
                                                                    )
                                                                    .refresh();
                                                              },
                                                        icon: RotationTransition(
                                                          turns:
                                                              _rotationController,
                                                          child: const Icon(
                                                            Icons.refresh,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Flexible(
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: context
                                                                  .l10n
                                                                  .updated,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  visibleTimetable
                                                                          ?.updated !=
                                                                      null
                                                                  ? getRelativeDayString(
                                                                      visibleTimetable!
                                                                          .updated!,
                                                                      context,
                                                                      timePattern:
                                                                          "Hm",
                                                                    )
                                                                  : '',
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                trailing: const Icon(
                                                  Icons.chevron_right,
                                                  size: 18,
                                                ),
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
                                await ref
                                    .read(timetableProvider.notifier)
                                    .refresh();
                              },
                              child:
                                  filteredTimetable == null ||
                                      filteredTimetable.entries.isEmpty
                                  ? LayoutBuilder(
                                      builder: (context, constraints) {
                                        return SingleChildScrollView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: SizedBox(
                                            height: constraints.maxHeight,
                                            child: Center(
                                              child: Text(
                                                context.l10n.noEntries,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : EntryList(
                                      timetable: filteredTimetable,
                                      settings: settingsState,
                                      filters: settingsState.filters,
                                      classFilter: settingsState.classFilter,
                                    ),
                            ),
                          ),
                        ],
                      );
              },
            );
          },
        );
      },
    );
  }
}
