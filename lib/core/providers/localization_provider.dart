import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/app_localizations.dart';

final localizationProvider = Provider<AsyncValue<AppLocalizations>>((ref) {
  final settings = ref.watch(settingsProvider);

  return settings.whenData((settings) {
    final locale =
        settings.locale ?? WidgetsBinding.instance.platformDispatcher.locale;

    final resolvedLocale = basicLocaleListResolution([
      locale,
    ], AppLocalizations.supportedLocales);

    return lookupAppLocalizations(resolvedLocale);
  });
});
