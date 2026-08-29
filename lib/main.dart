import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planner/background_tasks.dart';
import 'package:planner/certificates.dart';
import 'package:planner/core/model/timetable.dart';
import 'package:planner/core/settings/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/providers/shared_preferences_provider.dart';
import 'package:planner/providers/timetable_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planner/screens/home_screen.dart';
import 'package:planner/screens/plan_screen.dart';
import 'package:planner/repo/data_repository.dart';
import 'package:planner/services/notification_service.dart';
import 'package:planner/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load settings: $error')),
        ),
      ),
      data: (data) {
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

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [Locale('en'), Locale('de')],

          locale: data.locale,

          home: const NavigatorScreen(),
        );
      },
    );
  }
}

class NavigatorScreen extends ConsumerStatefulWidget {
  const NavigatorScreen({super.key});

  @override
  ConsumerState<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends ConsumerState<NavigatorScreen> {
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
