import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:planner/app/root.dart';
import 'package:planner/certificates.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/notifications/notification_service.dart';
import 'package:planner/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final locale = PlatformDispatcher.instance.locale.toString();
  await initializeDateFormatting(locale);

  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
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
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp(
              title: 'Vertretungsplan',
              debugShowCheckedModeBanner: false,

              theme: createLightTheme(
                themeColor: data.themeColor,
                dynamicLight: lightDynamic,
              ),

              darkTheme: data.darkTheme == DarkTheme.amoled
                  ? createAmoledTheme(
                      themeColor: data.themeColor,
                      dynamicDark: darkDynamic,
                    )
                  : createDarkTheme(
                      themeColor: data.themeColor,
                      dynamicDark: darkDynamic,
                    ),

              themeMode: switch (data.theme) {
                AppThemes.system => ThemeMode.system,
                AppThemes.light => ThemeMode.light,
                AppThemes.dark => ThemeMode.dark,
              },

              localizationsDelegates: [
                ...GlobalMaterialLocalizations.delegates,
                AppLocalizations.delegate,
              ],

              supportedLocales: const [Locale('en'), Locale('de')],

              locale: data.locale,

              home: const AppRoot(),
            );
          },
        );
      },
    );
  }
}
