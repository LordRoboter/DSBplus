import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planner/screens/home_screen.dart';
import 'package:planner/screens/plan_screen.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/services/notification_service.dart'
    show NotificationService;
import 'package:planner/theme.dart';
import 'package:planner/util/date.dart';
import 'package:planner/util/sorter.dart';

import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/settings_screen.dart';
import 'services/plan_repository.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

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
    final data = context.watch<DataRepository>();

    return MaterialApp(
      title: 'Vertretungsplan',
      debugShowCheckedModeBanner: false,

      theme: lightTheme,
      darkTheme: switch (data.darkTheme) {
        DarkTheme.dark => darkTheme,
        DarkTheme.amoled => amoledTheme,
      },

      themeMode: switch (data.theme) {
        AppThemes.system => ThemeMode.system,
        AppThemes.light => ThemeMode.light,
        AppThemes.dark => ThemeMode.dark,
      },

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

  late final StreamSubscription _sub;

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
    final data = context.read<DataRepository>();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data["type"] != "timetable_updated") return;

      await NotificationService.showUpdateNotification();
      await plan.loadData();
    });

    _sub = data.updates.listen((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Neue Einträge!"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
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

  final settings = await SharedPreferences.getInstance();

  final backgroundNotifications = settings.getBool("notifications") ?? true;

  if (!backgroundNotifications) {
    return; // don't show notification, but still allow Firebase processing
  }

  final data = DataRepository();
  await data.init();
  final oldData = await data.sync();

  /*[
    {
      "dayDate": "Freitag",
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
      "dayDate": "Donnerstag",
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
      "dayDate": "Freitag",
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

  final groupedNew = groupEntriesByAllowedDayDates(
    newData,
    data.availableDayDates,
  );
  final groupedOld = groupEntriesByAllowedDayDates(
    oldData,
    data.availableDayDates,
  );

  for (final dayDate in data.availableDayDates) {
    final diff = diffByClass(
      groupedOld[dayDate] ?? [],
      groupedNew[dayDate] ?? [],
      data.classFilter,
    );

    if (diff.added.isNotEmpty || diff.removed.isNotEmpty) {
      final sample = diff.added.isNotEmpty
          ? diff.added.first
          : diff.removed.first;

      final relativeDay = getRelativeDay(sample["date"]);
      final dayName =
          relativeDay.toLowerCase() == "heute" ||
              relativeDay.toLowerCase() == "heute"
          ? relativeDay
          : "$dayDate $relativeDay";
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
        if (diff.added.isNotEmpty) addedEntries,
        if (diff.removed.isNotEmpty) removedEntries,
      ].join("\n");

      await NotificationService.makeUpdateNotification(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 +
            data.availableDayDates.indexOf(dayDate),
        title,
        details,
      );
    }
  }
}

//TODO: Fix this, find the issue with the certificate on some devices...
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    client
        .badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (host == "dsbmobile.de") {
        final fingerprint = certificateSha256(cert);

        return fingerprint ==
            "8C54C334B66BA4E426772AF4A3F9136C19A1AEC729FDB28C535C07A5A4EF22E0";
      }

      return false;
    };

    return client;
  }
}

String certificateSha256(X509Certificate cert) {
  return sha256.convert(cert.der).toString().toUpperCase();
}
