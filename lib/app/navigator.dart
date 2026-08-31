import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/notifications/notification_service.dart';
import 'package:planner/features/settings/presentation/settings_screen.dart';
import 'package:planner/features/timetables/model/timetable.dart';
import 'package:planner/features/timetables/presentation/home_screen.dart';
import 'package:planner/features/timetables/presentation/plan_screen.dart';
import 'package:planner/features/timetables/providers/timetable_provider.dart';
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

  @override
  void initState() {
    super.initState();

    ref.read(timetableProvider);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data["type"] != "timetable_updated") return;

      await NotificationService.showUpdateNotification();
      if (!mounted) return;
      await ref.read(timetableProvider.notifier).refresh();
    });

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.substPlan),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: openSettings),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_month),
            label: context.l10n.plan,
          ),
        ],
      ),
    );
  }
}
