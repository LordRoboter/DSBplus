import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n {
    final l10n = AppLocalizations.of(this);
    if (l10n == null) {
      throw FlutterError(
        'AppLocalizations not found in context. '
        'Make sure AppLocalizations.delegate is in localizationsDelegates.',
      );
    }
    return l10n;
  }
}
