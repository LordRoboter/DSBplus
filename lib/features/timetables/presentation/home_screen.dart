import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/features/timetables/providers/enhanced_timetables_provider.dart';
import 'package:planner/features/timetables/providers/timetable_provider.dart';
import 'package:planner/features/timetables/presentation/widgets/lists.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/features/timetables/presentation/widgets/modals.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final timetables = ref.watch(filteredEnhancedTimetablesProvider);
    final settings = ref.watch(settingsProvider);
    final isRefreshing = ref.watch(timetableRefreshingProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settingsState) {
        return timetables.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (enhancedTimetables) {
            return RefreshIndicator(
              onRefresh: () async {
                return ref.read(timetableProvider.notifier).refresh();
              },
              child: enhancedTimetables.isEmpty
                  ? !isRefreshing
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: Center(
                                    child: Text(context.l10n.noRelevantEntries),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: enhancedTimetables.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 48),
                      itemBuilder: (context, index) {
                        final dayTimetable = enhancedTimetables.elementAt(
                          index,
                        );

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Material(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      showDragHandle: true,
                                      builder: (context) {
                                        return PlanDetailsSheet(
                                          timetable: dayTimetable,
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dayName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                          ),
                                        ),
                                        if (date != null && isOutdated(date))
                                          Tooltip(
                                            message: context.l10n.outdatedEntry,
                                            child: Icon(
                                              Icons.warning_amber_rounded,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: EntryListNoScroll(
                                timetable: dayTimetable,
                                settings: settingsState,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}
