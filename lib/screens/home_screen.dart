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
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PlanRepository>();
    final data = context.watch<DataRepository>();

    final classResults = filterByClass(repo.entries, data.classFilter);
    final groupedByDay = sortEntries(classResults, data.clean, data.simplify);
    return ListView.separated(
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
                        "${dayEntry.key} ${getRelativeDay(dayEntry.value.values.first.first["date"])}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (isOutdated(dayEntry.value.values.first.first["date"]))
                      Tooltip(
                        message: "Dieser Eintrag ist wahrscheinlich veraltet",
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
    );
  }
}
