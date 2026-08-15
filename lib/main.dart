import 'dart:io';
import 'dart:ui';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planner/background_tasks.dart';
import 'package:planner/certificates.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:workmanager/workmanager.dart';
import 'l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planner/screens/home_screen.dart';
import 'package:planner/screens/plan_screen.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/services/notification_service.dart';
import 'package:planner/theme.dart';

import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  await Workmanager().initialize(callbackDispatcher);

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
