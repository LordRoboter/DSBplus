import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planner/app/root.dart';
import 'package:planner/background_tasks.dart';
import 'package:planner/certificates.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planner/features/notifications/notification_service.dart';
import 'package:planner/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic("vertretungsplan");

    await Workmanager().initialize(callbackDispatcher);
  }

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

          home: const AppRoot(),
        );
      },
    );
  }
}
