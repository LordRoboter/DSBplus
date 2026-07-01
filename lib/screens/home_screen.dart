import 'package:flutter/material.dart';
import 'package:planner/components/lists.dart';
import 'package:provider/provider.dart';

import '../services/plan_repository.dart';
import '../util/sorter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PlanRepository>();
    final classResults = filterByClass(repo.entries, repo.classFilter);
    final dayResult = groupEntriesByDay(classResults);
    final groupedByDay = <String, Map<String, List<Map<String, dynamic>>>>{};
    for (final entry in dayResult.entries) {
      var res = entry.value;

      if (repo.clean) {
        res = cleanupEntries(res);
      }

      if (repo.simplify) {
        res = simplifyEntries(res);
      }

      groupedByDay[entry.key] = groupEntries(res);
    }
    return ListView(
      children: groupedByDay.entries.map((dayEntry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                dayEntry.key,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            EntryListNoScroll(groups: dayEntry.value),
          ],
        );
      }).toList(),
    );
  }
}
