import 'package:flutter/material.dart';
import 'package:planner/components/lists.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/util/sorter.dart';
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

    if (data.selectedDay == null && repo.availableDays.isNotEmpty) {
      data.setSelectedDay(repo.availableDays.first);
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

    final sortedEntries = sortEntries(
      repo.entries,
      data.clean,
      data.simplify,
      disposeTut: data.disposeTut,
      cleanClassNames: data.cleanClassNames,
      remapTypes: data.remapTypes,
      cleanupCourses: data.cleanupCourses,
      disposeCourseNumbers: data.disposeCourseNumbers,
      mapCourses: data.mapCourses,
    );
    final visibleGroups = data.selectedDay != null
        ? sortedEntries[data.selectedDay] ??
              <String, List<Map<String, dynamic>>>{}
        : <String, List<Map<String, dynamic>>>{};

    final filteredGroups = isSearching
        ? visibleGroups.map(
            (group, entries) => MapEntry(
              group,
              entries.where((e) => matches(e, search)).toList(),
            ),
          )
        : visibleGroups;

    return repo.error != null
        ? RefreshIndicator(
            onRefresh: () async {
              await repo.loadData();
            },
            child: Center(child: Text(repo.error!)),
          )
        : Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isSearching
                    ? TextField(
                        key: const ValueKey('search'),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => isSearching = false);
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            search = value.toLowerCase();
                          });
                        },
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
                                    itemCount: repo.availableDays.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final day = repo.availableDays[index];

                                      return ChoiceChip(
                                        label: Text(day),
                                        selected: data.selectedDay == day,
                                        onSelected: (_) {
                                          data.setSelectedDay(day);
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
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 6),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Datum: ",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "${visibleGroups.values.first.first['date'] ?? ''}",
                                      ),
                                    ],
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                SizedBox(
                                  height: 18.0,
                                  width: 18.0,
                                  child: IconButton(
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    splashRadius: 18,
                                    onPressed: repo.loading
                                        ? null
                                        : () async {
                                            await repo.loadData();
                                          },
                                    icon: RotationTransition(
                                      turns: _rotationController,
                                      child: const Icon(Icons.refresh),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Updated: ",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "${visibleGroups.values.first.first['updated'] ?? ''}",
                                      ),
                                    ],
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
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
                  child: EntryList(
                    groups: filteredGroups,
                    classFilter: data.classFilter,
                  ),
                ),
              ),
            ],
          );
  }
}
