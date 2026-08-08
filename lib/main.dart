import 'dart:io';
import 'dart:ui';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/models/daydate.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/core/util/translations.dart';
import 'l10n/app_localizations.dart';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planner/screens/home_screen.dart';
import 'package:planner/screens/plan_screen.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/services/notification_service.dart';
import 'package:planner/theme.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/core/util/sorter.dart';

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

  final locale = PlatformDispatcher.instance.locale.toString();
  await initializeDateFormatting(locale);

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

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('de')],
      locale: data.locale,

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
        SnackBar(
          content: Text(context.l10n.newEntries),
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
        title: Text(context.l10n.substPlan),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: context.l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_month),
            label: context.l10n.plan,
          ),
        ],
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.data["type"] != "timetable_updated") return;

  final settings = await SharedPreferences.getInstance();

  final backgroundNotifications = settings.getBool("notifications") ?? true;

  if (!backgroundNotifications) {
    return;
  }

  final data = DataRepository();
  await data.init();

  final oldData = await data.sync();
  final newData = data.cachedEntries;

  final groupedOld = {
    for (final timetable in oldData)
      DayDate(timetable.day, timetable.date): timetable,
  };

  final groupedNew = {
    for (final timetable in newData)
      DayDate(timetable.day, timetable.date): timetable,
  };

  final localeCode = PlatformDispatcher.instance.locale.languageCode;
  final l10n = await AppLocalizations.delegate.load(Locale(localeCode));
  await initializeDateFormatting(localeCode);

  for (final dayDate in data.availableDayDates) {
    final diff = diffByClass(
      groupedOld[dayDate],
      groupedNew[dayDate],
      data.classFilter.classes,
    );

    if (!diff.hasChanges) continue;

    final date = dayDate.date!;
    final formattedDate = DateFormat.yMd(Locale(localeCode)).format(date);

    final relativeDay = getRelativeDay(date);

    final dayName = switch (relativeDay) {
      0 => l10n.today,
      1 => l10n.tomorrow,
      -1 => l10n.yesterday,
      _ => "${dayDate.day} ($formattedDate)",
    };

    final title = diff.added.isNotEmpty && diff.removed.isNotEmpty
        ? "$dayName: ${l10n.timetableChanged}"
        : diff.added.isNotEmpty
        ? "$dayName: ${l10n.newEntries}"
        : "$dayName: ${l10n.deletedEntries}";

    final addedEntries = diff.added
        .map(
          (entry) => l10n.entryInfo(
            ordinal(entry.entry.lesson, Locale(localeCode)),
            entry.entry.type ?? "",
            entry.entry.subject ?? "",
            entry.entry.teacher ?? "",
          ),
        )
        .join("\n");

    final removedEntries = diff.removed
        .map(
          (entry) => l10n.entryInfoDeleted(
            ordinal(entry.entry.lesson, Locale(localeCode)),
            entry.entry.type ?? "",
            entry.entry.subject ?? "",
            entry.entry.teacher ?? "",
          ),
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
