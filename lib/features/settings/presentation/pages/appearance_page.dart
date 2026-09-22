import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/app/navigation/model/navigation_item.dart';
import 'package:planner/features/settings/model/navigation_settings.dart';
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

                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(context.l10n.themeColor),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ThemeChoice(
                              title: context.l10n.defaultt,
                              icon: Icons.palette_outlined,
                              selected: settings.themeColor is StandardColor,
                              onTap: () {
                                notifier.setThemeColor(const StandardColor());
                              },
                            ),
                          ),
                          Expanded(
                            child: _ThemeChoice(
                              title: context.l10n.dynamicc,
                              icon: Icons.auto_awesome,
                              selected: settings.themeColor is DynamicColor,
                              onTap: () {
                                notifier.setThemeColor(const DynamicColor());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: themeColors.length + 1,
                      itemBuilder: (context, index) {
                        if (index < themeColors.length) {
                          final color = themeColors[index];
                          return Center(
                            child: _ThemeColorButton(
                              color: color,
                              selected:
                                  settings.themeColor is CustomColor &&
                                  (settings.themeColor as CustomColor).color
                                          .toARGB32() ==
                                      color.toARGB32(),
                              onTap: () {
                                notifier.setThemeColor(CustomColor(color));
                              },
                            ),
                          );
                        }
                        return Center(
                          child: _CustomColorButton(
                            color: settings.themeColor is CustomColor
                                ? (settings.themeColor as CustomColor).color
                                : null,
                            selected:
                                settings.themeColor is CustomColor &&
                                !themeColors.any(
                                  (color) =>
                                      color.toARGB32() ==
                                      (settings.themeColor as CustomColor).color
                                          .toARGB32(),
                                ),
                            onColorSelected: (color) {
                              notifier.setThemeColor(CustomColor(color));
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                      child: Text("context.l10n.navigation"),
                    ),
                    _NavigationOrderEditor(
                      items: settings.bottomNavigationItems,
                      onChanged: notifier.setBottomNavigationItems,
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

class _NavigationOrderEditor extends StatefulWidget {
  const _NavigationOrderEditor({required this.items, required this.onChanged});

  final List<NavigationItemSettings> items;
  final ValueChanged<List<NavigationItemSettings>> onChanged;

  @override
  State<_NavigationOrderEditor> createState() => _NavigationOrderEditorState();
}

class _NavigationOrderEditorState extends State<_NavigationOrderEditor> {
  late List<NavigationItemSettings> items;

  @override
  void initState() {
    super.initState();
    items = [...widget.items];
  }

  @override
  void didUpdateWidget(covariant _NavigationOrderEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      items = [...widget.items];
    }
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }

      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });

    widget.onChanged(items);
  }

  void _toggle(int index, bool value) {
    // Don't allow the user to hide everything.
    final visibleCount = items.where((item) => item.visible).length;

    if (!value && visibleCount <= 1) {
      return;
    }

    setState(() {
      items[index] = NavigationItemSettings(
        item: items[index].item,
        visible: value,
      );
    });

    widget.onChanged(items);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorder: _reorder,
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          key: ValueKey(item.item),
          leading: Icon(_iconFor(item.item)),
          title: Text(_labelFor(context, item.item)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: item.visible,
                onChanged: (value) => _toggle(index, value),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.drag_handle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconFor(NavigationItem item) {
    return switch (item) {
      NavigationItem.home => Icons.home_outlined,
      NavigationItem.plan => Icons.calendar_month_outlined,
      NavigationItem.resources => Icons.article_outlined,
    };
  }

  String _labelFor(BuildContext context, NavigationItem item) {
    return switch (item) {
      NavigationItem.home => context.l10n.home,
      NavigationItem.plan => context.l10n.plan,
      NavigationItem.resources => context.l10n.resources,
    };
  }
}

class _ThemeColorSplitButton extends StatelessWidget {
  const _ThemeColorSplitButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isLeft,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final radius = BorderRadius.horizontal(
      left: isLeft ? const Radius.circular(12) : Radius.zero,
      right: !isLeft ? const Radius.circular(12) : Radius.zero,
    );

    final border = BorderSide(
      color: selected ? colorScheme.primary : colorScheme.outlineVariant,
      width: selected ? 2 : 1,
    );

    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: radius, side: border),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check : icon,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeColorButton extends StatelessWidget {
  const _ThemeColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
  }) : icon = null;

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

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
            child: icon != null
                ? Icon(
                    icon,
                    size: 20,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  )
                : selected
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

class _CustomColorButton extends StatelessWidget {
  const _CustomColorButton({
    required this.color,
    required this.selected,
    required this.onColorSelected,
  });

  final Color? color;
  final bool selected;
  final ValueChanged<Color> onColorSelected;

  Future<void> _pickColor(BuildContext context) async {
    var pickedColor = color ?? Colors.blue;
    final result = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.customColor),
          content: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        height: 72,
                        decoration: BoxDecoration(
                          color: pickedColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '#${pickedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: pickedColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ColorPicker(
                        color: pickedColor,
                        onColorChanged: (value) {
                          setState(() {
                            pickedColor = value;
                          });
                        },
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.primary: false,
                          ColorPickerType.accent: false,
                        },
                        enableShadesSelection: true,
                        enableOpacity: false,
                        wheelDiameter: 240,
                        wheelWidth: 24,
                        showColorCode: false,
                        showColorName: false,
                        heading: const SizedBox.shrink(),
                        subheading: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(pickedColor);
              },
              child: Text(context.l10n.select),
            ),
          ],
        );
      },
    );
    if (result != null) {
      onColorSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickColor(context),
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
            decoration: BoxDecoration(
              color: color ?? colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: color == null
                ? Icon(
                    Icons.colorize,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  )
                : selected
                ? Icon(
                    Icons.check,
                    size: 20,
                    color: color!.computeLuminance() > 0.5
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

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.check : icon,
                  size: 18,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
