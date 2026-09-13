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
        final setLocale = ref.read(settingsProvider.notifier).setLocale;

        return SettingsPageScaffold(
          title: context.l10n.language,
          child: SettingsSectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RadioGroup<Locale?>(
              groupValue: settings.locale,
              onChanged: setLocale,
              child: Column(
                children: [
                  _LanguageOption(
                    title: context.l10n.systemDefault,
                    subtitle:
                        nativeLanguageNames[systemLocale.languageCode] ??
                        'English',
                    value: null,
                    isSelected: settings.locale == null,
                    onTap: () => setLocale(null),
                  ),
                  const SizedBox(height: 8),
                  _LanguageOption(
                    title: 'English',
                    subtitle: 'English',
                    value: const Locale('en'),
                    isSelected: settings.locale == const Locale('en'),
                    onTap: () => setLocale(const Locale('en')),
                  ),
                  const SizedBox(height: 8),
                  _LanguageOption(
                    title: 'Deutsch',
                    subtitle: 'Deutsch',
                    value: const Locale('de'),
                    isSelected: settings.locale == const Locale('de'),
                    onTap: () => setLocale(const Locale('de')),
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Locale? value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<Locale?>(value: value),
            ],
          ),
        ),
      ),
    );
  }
}
