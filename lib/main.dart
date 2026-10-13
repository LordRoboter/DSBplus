import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:planner/app/root.dart';
import 'package:planner/background_tasks.dart';
import 'package:planner/certificates.dart';
import 'package:planner/core/providers/http_overrides_provider.dart';
import 'package:planner/core/widgets/error_view.dart';
import 'package:planner/features/settings/errors/presentation/error_page.dart';
import 'package:planner/features/settings/errors/providers/error_provider.dart';
import 'package:planner/features/settings/providers/background_settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/core/providers/shared_preferences_provider.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/notifications/notification_service.dart';
import 'package:planner/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final holder = HttpOverridesHolder();

  final providerContainer = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      httpOverridesHolderProvider.overrideWithValue(holder),
    ],
  );

  final errorNotifier = providerContainer.read(errorProvider.notifier);
  final errorState = await providerContainer.read(errorProvider.future);

  late final MyHttpOverrides overrides;

  overrides = MyHttpOverrides(
    trustedFingerprint: errorState.trustedFingerprint,
    autoTrustCertificates: errorState.autoTrustCertificates,

    onFailedFingerprint: (fingerprint) async {
      debugPrint('Certificate failure detected: $fingerprint');

      await errorNotifier.setLastFailedFingerprint(fingerprint);
    },

    onTrustFingerprint: (fingerprint) async {
      await errorNotifier.trustFingerprint(fingerprint);
      overrides.updateTrustedFingerprint(fingerprint);
    },
  );

  holder.instance = overrides;
  HttpOverrides.global = overrides;

  final locale = PlatformDispatcher.instance.locale.toString();
  await initializeDateFormatting(locale);

  await NotificationService.init();
  await Workmanager().initialize(callbackDispatcher);

  final backgroundSettings = BackgroundSettingsRepository();
  await backgroundSettings.init();

  await scheduleNextBackgroundCheck(backgroundSettings.backgroundSchedule);

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const CertificateErrorSnackBarListener(),
    ),
  );
}

final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final _navigatorKey = GlobalKey<NavigatorState>();

class CertificateErrorSnackBarListener extends ConsumerStatefulWidget {
  const CertificateErrorSnackBarListener({super.key});

  @override
  ConsumerState<CertificateErrorSnackBarListener> createState() =>
      _CertificateErrorSnackBarListenerState();
}

class _CertificateErrorSnackBarListenerState
    extends ConsumerState<CertificateErrorSnackBarListener> {
  bool _hasShownCertificateError = false;

  void _showCertificateErrorSnackBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigatorContext = _navigatorKey.currentContext;
      if (navigatorContext == null || !mounted) return;

      final l10n = navigatorContext.l10n;
      final messenger = _scaffoldMessengerKey.currentState;

      if (messenger == null) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.certificateErrorSnackbar),
          action: SnackBarAction(
            label: l10n.openCertificateSettings,
            onPressed: () {
              _navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => const ErrorSettingsPage()),
              );
            },
          ),
        ),
      );
    });
  }

  void _handleCertificateError(
    String? fingerprint,
    String? trustedFingerprint,
    bool autoTrust,
  ) {
    if (_hasShownCertificateError ||
        fingerprint == null ||
        fingerprint == trustedFingerprint ||
        autoTrust) {
      return;
    }

    _hasShownCertificateError = true;

    _showCertificateErrorSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    ref.listen(errorProvider, (previous, next) {
      next.whenData((errors) {
        _handleCertificateError(
          errors.lastFailedFingerprint,
          errors.trustedFingerprint,
          errors.autoTrustCertificates,
        );
      });
    });

    final errorState = ref.watch(errorProvider);
    errorState.whenData((errors) {
      if (!_hasShownCertificateError && errors.lastFailedFingerprint != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleCertificateError(
              errors.lastFailedFingerprint,
              errors.trustedFingerprint,
              errors.autoTrustCertificates,
            );
          }
        });
      }
    });

    return settings.when(
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: ErrorView(
              title: 'Something went wrong',
              message: 'Settings could not be loaded. ',
            ),
          ),
        ),
      ),
      data: (data) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp(
              scaffoldMessengerKey: _scaffoldMessengerKey,
              navigatorKey: _navigatorKey,
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
