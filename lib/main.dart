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

  await initializeDateFormatting('de_DE');

  if (message.data["type"] != "timetable_updated") return;

  final data = DataRepository();
  await data.init();
  final oldData = await data.sync();

  final groupedNew = groupEntriesByAllowedDays(
    data.cachedEntries,
    data.availableDays,
  );
  final groupedOld = groupEntriesByAllowedDays(oldData, data.availableDays);

  for (final day in data.availableDays) {
    final diff = diffByClass(
      groupedOld[day]!,
      groupedNew[day]!,
      data.classFilter,
    );

    if (diff.added.isNotEmpty || diff.removed.isNotEmpty) {
      final relativeDay = getRelativeDay(diff.added.first["date"]);
      final dayName =
          relativeDay.toLowerCase() == "heute" ||
              relativeDay.toLowerCase() == "heute"
          ? relativeDay
          : "$day ($relativeDay)";
      final title = diff.added.isNotEmpty && diff.removed.isNotEmpty
          ? "Veränderter Vertretungsplan für $dayName"
          : diff.added.isNotEmpty
          ? "Neue Einträge für $dayName"
          : "Gelöschte Einträge für $dayName";

      final addedEntries = diff.added
          .map((entry) => "${entry["lesson"]}: ${entry["type"]}")
          .join("\n");

      final removedEntries = diff.removed
          .map((entry) => "${entry["lesson"]}: ${entry["type"]}")
          .join("\n");

      final details = [
        if (diff.added.isNotEmpty) "Neu:\n$addedEntries",
        if (diff.removed.isNotEmpty) "Entfernt:\n$removedEntries",
      ].join("\n\n");

      await NotificationService.makeUpdateNotification(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        details,
      );
    }
  }
}
