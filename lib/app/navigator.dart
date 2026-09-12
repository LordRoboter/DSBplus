import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/settings/presentation/settings_screen.dart';
import 'package:planner/features/dsb/resources/presentation/dsb_resources_screen.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:planner/features/dsb/timetables/presentation/home_screen.dart';
import 'package:planner/features/dsb/timetables/presentation/plan_screen.dart';
import 'package:planner/features/dsb/timetables/providers/timetable_provider.dart';
import 'package:planner/l10n/l10extension.dart';

class NavigatorScreen extends ConsumerStatefulWidget {
  const NavigatorScreen({super.key});

  @override
  ConsumerState<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends ConsumerState<NavigatorScreen> {
  int index = 0;

  final pages = const [HomeScreen(), PlanScreen()];

  Future<void> openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> openResources() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DsbResourcesScreen()),
    );
  }

  @override
  void initState() {
    super.initState();

    ref.read(timetableProvider);

    ref.listenManual<AsyncValue<List<Timetable>>>(timetableProvider, (
      previous,
      next,
    ) {
      final oldTimetables = previous?.value;
      final newTimetables = next.value;

      if (oldTimetables == null || newTimetables == null) {
        return;
      }

      const equality = DeepCollectionEquality();

      if (equality.equals(
        oldTimetables.map((e) => e.toComparableJson()).toList(),
        newTimetables.map((e) => e.toComparableJson()).toList(),
      )) {
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.newEntries),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(index == 0 ? context.l10n.substPlan : context.l10n.plan),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: openSettings),
        ],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Planner',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title: Text(context.l10n.home),
                selected: index == 0,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => index = 0);
                },
              ),

              ListTile(
                leading: const Icon(Icons.calendar_view_month),
                title: Text(context.l10n.plan),
                selected: index == 1,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => index = 1);
                },
              ),

              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(context.l10n.resources),
                onTap: () {
                  Navigator.pop(context);
                  openResources();
                },
              ),

              const Spacer(),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(context.l10n.settings),
                onTap: () {
                  Navigator.pop(context);
                  openSettings();
                },
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(index: index, children: pages),

      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
        },
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_view_month),
            label: context.l10n.plan,
          ),
        ],
      ),
    );
  }
}
