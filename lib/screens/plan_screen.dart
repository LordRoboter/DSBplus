import 'package:flutter/material.dart';
import 'package:planner/components/lists.dart';
import 'package:planner/util/sorter.dart';
import 'package:provider/provider.dart';

import '../services/plan_repository.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  var isSearching = false;
  String search = "";

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PlanRepository>();

    final visibleGroups = repo.groupedEntries[repo.selectedDay] ?? {};

    final filteredGroups = isSearching
        ? visibleGroups.map(
            (group, entries) => MapEntry(
              group,
              entries.where((e) => matches(e, search)).toList(),
            ),
          )
        : visibleGroups;

    return repo.loading
        ? const Center(child: CircularProgressIndicator())
        : repo.error != null
        ? Center(child: Text(repo.error!))
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
                                        selected: repo.selectedDay == day,
                                        onSelected: (_) => repo.selectDay(day),
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
                                const Icon(Icons.update, size: 16),
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
                                      TextSpan(text: repo.lastUpdated),
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
                    classFilter: repo.classFilter,
                  ),
                ),
              ),
            ],
          );
  }
}
