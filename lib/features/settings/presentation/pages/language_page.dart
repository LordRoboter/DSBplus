import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';

const nativeLanguageNames = {'de': 'Deutsch', 'en': 'English'};

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        return SettingsPageScaffold(
          title: context.l10n.language,
          child: SettingsSectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RadioGroup<Locale?>(
              groupValue: settings.locale,
              onChanged: ref.read(settingsProvider.notifier).setLocale,
              child: Column(
                children: [
                  RadioListTile<Locale?>(
                    title: Text(
                      '${context.l10n.systemDefault} '
                      '(${nativeLanguageNames[systemLocale.languageCode] ?? 'English'})',
                    ),
                    value: null as Locale?,
                  ),
                  RadioListTile<Locale?>(
                    title: Text(
                      context.l10n.english == 'English'
                          ? 'English'
                          : '${context.l10n.english} (English)',
                    ),
                    value: const Locale('en'),
                  ),
                  RadioListTile<Locale?>(
                    title: Text(
                      context.l10n.german == 'Deutsch'
                          ? 'Deutsch'
                          : '${context.l10n.german} (Deutsch)',
                    ),
                    value: const Locale('de'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
