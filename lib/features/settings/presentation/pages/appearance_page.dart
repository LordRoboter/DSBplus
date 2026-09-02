import 'package:material_ui/material_ui.dart';
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
        final colorScheme = Theme.of(context).colorScheme;

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
                    // App theme
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
                        selectedBackgroundColor: colorScheme.primaryContainer,
                        selectedForegroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dark theme
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
                        selectedBackgroundColor: colorScheme.primaryContainer,
                        selectedForegroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Theme color
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(context.l10n.themeColor),
                    ),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Default color
                        _ThemeColorButton(
                          color: Colors.blue,
                          selected: settings.themeColor == null,
                          onTap: () {
                            notifier.setThemeColor(null);
                          },
                        ),

                        // Custom colors
                        ...themeColors.map(
                          (color) => _ThemeColorButton(
                            color: color,
                            selected:
                                settings.themeColor?.toARGB32() ==
                                color.toARGB32(),
                            onTap: () {
                              notifier.setThemeColor(color);
                            },
                          ),
                        ),
                      ],
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

class _ThemeColorButton extends StatelessWidget {
  const _ThemeColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 20,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
