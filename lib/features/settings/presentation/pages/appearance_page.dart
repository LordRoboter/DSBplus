import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/theme.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        final notifier = ref.read(settingsProvider.notifier);

        return SettingsPageScaffold(
          title: context.l10n.appearance,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(context.l10n.appTheme),
                    ),
                    SegmentedButton<AppThemes>(
                      segments: [
                        ButtonSegment<AppThemes>(
                          value: AppThemes.system,
                          icon: const Icon(Icons.brightness_auto),
                          label: Text(context.l10n.system),
                        ),
                        ButtonSegment<AppThemes>(
                          value: AppThemes.light,
                          icon: const Icon(Icons.light_mode),
                          label: Text(context.l10n.light),
                        ),
                        ButtonSegment<AppThemes>(
                          value: AppThemes.dark,
                          icon: const Icon(Icons.dark_mode),
                          label: Text(context.l10n.dark),
                        ),
                      ],
                      selected: {settings.theme},
                      onSelectionChanged: (newSelection) {
                        if (newSelection.isNotEmpty) {
                          notifier.setTheme(newSelection.first);
                        }
                      },
                      style: SegmentedButton.styleFrom(
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        selectedBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        selectedForegroundColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(context.l10n.darkTheme),
                    ),
                    SegmentedButton<DarkTheme>(
                      segments: [
                        ButtonSegment<DarkTheme>(
                          value: DarkTheme.dark,
                          icon: const Icon(Icons.dark_mode),
                          label: Text(context.l10n.standard),
                        ),
                        ButtonSegment<DarkTheme>(
                          value: DarkTheme.amoled,
                          icon: const Icon(Icons.brightness_2),
                          label: Text(context.l10n.amoled),
                        ),
                      ],
                      selected: {settings.darkTheme},
                      onSelectionChanged: (newSelection) {
                        if (newSelection.isNotEmpty) {
                          notifier.setDarkTheme(newSelection.first);
                        }
                      },
                      style: SegmentedButton.styleFrom(
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        selectedBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        selectedForegroundColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
