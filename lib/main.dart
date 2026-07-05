import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planner/screens/home_screen.dart';
import 'package:planner/screens/plan_screen.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/services/notification_service.dart'
    show NotificationService;
import 'package:planner/util/date.dart';
import 'package:planner/util/sorter.dart';

import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/settings_screen.dart';
import 'services/plan_repository.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  await FirebaseMessaging.instance.subscribeToTopic("vertretungsplan");

  await initializeDateFormatting('de_DE');

  final dataRepository = DataRepository();
  await dataRepository.init();

  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dataRepository),
        ChangeNotifierProvider(
          create: (_) => PlanRepository(dataRepository)..init(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertretungsplan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const NavigatorScreen(),
    );
  }
}

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
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

    final plan = context.read<PlanRepository>();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.data["type"]);
      if (message.data["type"] != "timetable_updated") return;

      await NotificationService.showUpdateNotification();
      await plan.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vertretungsplan"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: openSettings),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_month),
            label: "Plan",
          ),
        ],
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("BACKGROUND HANDLER STARTED");

  await initializeDateFormatting('de_DE');

  if (message.data["type"] != "timetable_updated") return;

  final data = DataRepository();
  await data.init();
  final oldData = await data.sync();

  /*[
    {
      "day": "Freitag",
      "date": "26.06.2026",
      "updated": "26.06.2026",
      "class": "7b",
      "lesson": "1",
      "subject": "D",
      "teacher": "Loh",
      "room": "102",
      "type": "Entfall",
    },
    {
      "day": "Donnerstag",
      "date": "25.06.2026",
      "updated": "26.06.2026",
      "class": "7b",
      "lesson": "3",
      "subject": "M",
      "teacher": "Cyb",
      "room": "102",
      "type": "Entfall",
    },
  ];*/

  final newData = data.cachedEntries;

  /*[
    {
      "day": "Freitag",
      "date": "26.06.2026",
      "updated": "26.06.2026",
      "class": "7b",
      "lesson": "2",
      "subject": "M",
      "teacher": "Cyb",
      "room": "102",
      "type": "Entfall",
    },
  ];*/

  final groupedNew = groupEntriesByAllowedDays(newData, data.availableDays);
  final groupedOld = groupEntriesByAllowedDays(oldData, data.availableDays);

  for (final day in data.availableDays) {
    final diff = diffByClass(
      groupedOld[day] ?? [],
      groupedNew[day] ?? [],
      data.classFilter,
    );

    print((groupedOld[day] ?? []).toString());
    print((groupedNew[day] ?? []).toString());
    if (diff.added.isNotEmpty || diff.removed.isNotEmpty) {
      final sample = diff.added.isNotEmpty
          ? diff.added.first
          : diff.removed.first;

      final relativeDay = getRelativeDay(sample["date"]);
      final dayName =
          relativeDay.toLowerCase() == "heute" ||
              relativeDay.toLowerCase() == "heute"
          ? relativeDay
          : "$day $relativeDay";
      final title = diff.added.isNotEmpty && diff.removed.isNotEmpty
          ? "$dayName: Vertretungsplanänderung"
          : diff.added.isNotEmpty
          ? "$dayName: Neue Einträge"
          : "$dayName: Gelöschte Einträge";

      final addedEntries = diff.added
          .map(
            (entry) =>
                "${entry["lesson"]}. Std.: ${entry["type"]} (${entry["subject"]} ${entry["teacher"]})",
          )
          .join("\n");

      final removedEntries = diff.removed
          .map(
            (entry) =>
                "${entry["lesson"]}. Std.: ${entry["type"]} (${entry["subject"]} ${entry["teacher"]}) - Entfernt",
          )
          .join("\n");

      final details = [
        if (diff.added.isNotEmpty) "$addedEntries",
        if (diff.removed.isNotEmpty) "$removedEntries",
      ].join("\n");

      await NotificationService.makeUpdateNotification(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 +
            data.availableDays.indexOf(day),
        title,
        details,
      );
    }
  }
}
