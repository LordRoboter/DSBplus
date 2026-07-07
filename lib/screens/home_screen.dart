import 'package:flutter/material.dart';
import 'package:planner/components/lists.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/util/date.dart';
import 'package:provider/provider.dart';

import '../services/plan_repository.dart';
import '../util/sorter.dart';

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

    final classResults = filterByClass(repo.entries, data.classFilter);

    final uniqueResults = <String, Map<String, dynamic>>{};

    final newFilters = data.filters
        .map((f) => Map<String, String>.from(f)..remove("class"))
        .toList();
    for (final filter in newFilters) {
      if (data.classFilter.trim() != "") {
        filter.remove("class");
      }
      final results = filterByInfo(classResults, filter);
      for (final item in results) {
        final key =
            "${item["class"]}_${item["lesson"]}_${item["subject"]}_${item["teacher"]}_${item["day"]}_${item["date"]}}";

        uniqueResults[key] = item;
      }
    }

    List<Map<String, dynamic>> finalResults;
    if (data.filters.isNotEmpty) {
      finalResults = uniqueResults.values.toList();
    } else {
      finalResults = classResults;
    }

    /*if (repo.loading && _refreshKey.currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshKey.currentState?.show();
      });
    }*/

    final groupedByDay = sortEntries(
      finalResults,
      data.clean,
      data.simplify,
      disposeTut: data.disposeTut,
      cleanClassNames: data.cleanClassNames,
      remapTypes: data.remapTypes,
      cleanupCourses: data.cleanupCourses,
      disposeCourseNumbers: data.disposeCourseNumbers,
      mapCourses: data.mapCourses,
    );
    return RefreshIndicator(
      //key: _refreshKey,
      onRefresh: () async {
        await repo.loadData();
      },

      child: groupedByDay.isEmpty && repo.loading
          ? const Center(child: CircularProgressIndicator())
          : groupedByDay.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const Center(
                      child: Text("Keine relevanten Einträge •︵•"),
                    ),
                  ),
                );
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: groupedByDay.length,
              separatorBuilder: (_, _) => const SizedBox(height: 48),
              itemBuilder: (context, index) {
                final dayEntry = groupedByDay.entries.elementAt(index);

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
                                "${dayEntry.value.values.first.first["day"]} ${getRelativeDay(dayEntry.value.values.first.first["date"])}",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                            if (isOutdated(
                              dayEntry.value.values.first.first["date"],
                            ))
                              Tooltip(
                                message:
                                    "Dieser Eintrag ist wahrscheinlich veraltet",
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
                      child: EntryListNoScroll(groups: dayEntry.value),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
