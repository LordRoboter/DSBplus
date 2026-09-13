import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/notifications/notification_service.dart';
import 'package:planner/features/settings/presentation/widgets/dialogues.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/features/dsb/timetables/model/filter.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/theme.dart';

enum LanguageOption { system, english, german }

class StartupSetupPage extends ConsumerStatefulWidget {
  const StartupSetupPage({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  ConsumerState<StartupSetupPage> createState() => _StartupSetupPageState();
}

class _StartupSetupPageState extends ConsumerState<StartupSetupPage> {
  final classController = TextEditingController();

  bool _notificationsLoading = false;
  bool _notificationsEnabled = false;

  int? _expandedSection;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  void _toggleSection(int index) {
    setState(() {
      _expandedSection = _expandedSection == index ? null : index;
    });
  }

  @override
  void dispose() {
    classController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationStatus() async {
    try {
      final enabled = await NotificationService.areNotificationsEnabled();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (_) {
      // Notification support should never prevent onboarding.
    }
  }

  Future<void> _setupNotifications() async {
    if (_notificationsLoading) return;

    setState(() {
      _notificationsLoading = true;
    });

    try {
      final authorized = await NotificationService.requestPermission();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = authorized;
      });

      if (!authorized) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.notificationsWereNotEnabled)),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.couldNotNotifications}: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _notificationsLoading = false;
        });
      }
    }
  }

  Future<void> _addClass() async {
    final className = classController.text.trim();

    if (className.isEmpty) return;

    final settings = ref.read(settingsProvider).requireValue;
    final notifier = ref.read(settingsProvider.notifier);

    final updatedClasses = {...settings.classFilter.classes, className};

    await notifier.setClassFilter(
      settings.classFilter.copyWith(classes: updatedClasses),
    );

    classController.clear();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeClass(String className) async {
    final settings = ref.read(settingsProvider).requireValue;
    final notifier = ref.read(settingsProvider.notifier);

    final updatedClasses = {...settings.classFilter.classes}..remove(className);

    await notifier.setClassFilter(
      settings.classFilter.copyWith(classes: updatedClasses),
    );
  }

  Future<void> _addAdvancedFilter() async {
    final filter = await showDialog<TimetableFilter>(
      context: context,
      builder: (_) => const FilterDialog(),
    );

    if (filter == null) return;

    await ref.read(settingsProvider.notifier).addFilter(filter);
  }

  Future<void> _editFilter(TimetableFilter filter) async {
    final updatedFilter = await showDialog<TimetableFilter>(
      context: context,
      builder: (_) => FilterDialog(initialFilter: filter),
    );

    if (updatedFilter == null) return;

    await ref
        .read(settingsProvider.notifier)
        .updateFilter(filter, updatedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (settings) {
        final colorScheme = Theme.of(context).colorScheme;
        final notifier = ref.read(settingsProvider.notifier);

        return Scaffold(
          //extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,

            actions: [
              PopupMenuButton<LanguageOption>(
                tooltip: context.l10n.language,
                icon: const Icon(Icons.language_rounded),
                padding: EdgeInsets.zero,
                onSelected: (option) {
                  final locale = switch (option) {
                    LanguageOption.system => null,
                    LanguageOption.english => const Locale('en'),
                    LanguageOption.german => const Locale('de'),
                  };

                  ref.read(settingsProvider.notifier).setLocale(locale);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: LanguageOption.system,
                    child: Text('System default'),
                  ),
                  const PopupMenuItem(
                    value: LanguageOption.english,
                    child: Text('English'),
                  ),
                  const PopupMenuItem(
                    value: LanguageOption.german,
                    child: Text('Deutsch'),
                  ),
                ],
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.tune_rounded, size: 48),

                    const SizedBox(height: 20),

                    Text(
                      context.l10n.finishSetup,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      context.l10n.customizePlanner,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─────────────────────────────────────────────
                    // FILTERS
                    // ─────────────────────────────────────────────
                    _SetupSection(
                      title: context.l10n.filters,
                      description: context.l10n.filtersDesc,
                      icon: Icons.filter_alt_outlined,
                      expanded: _expandedSection == 0,
                      onToggle: () => _toggleSection(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: classController,
                            decoration: InputDecoration(
                              labelText: context.l10n.classFilter,
                              hintText: context.l10n.classFilterHint,
                              prefixIcon: const Icon(Icons.class_outlined),
                              suffixIcon: classController.text.trim().isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: _addClass,
                                    )
                                  : null,
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addClass(),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),

                          if (settings.classFilter.classes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: settings.classFilter.classes.map((
                                className,
                              ) {
                                return Chip(
                                  label: Text(className),
                                  onDeleted: () => _removeClass(className),
                                  deleteIcon: const Icon(Icons.close),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 16),

                          if (settings.filters.isNotEmpty)
                            ...settings.filters.map(
                              (filter) => SettingsFilterTile(
                                filter: filter,
                                onEdit: () => _editFilter(filter),
                                onDelete: () => notifier.removeFilter(filter),
                              ),
                            ),

                          OutlinedButton.icon(
                            onPressed: _addAdvancedFilter,
                            icon: const Icon(Icons.add),
                            label: Text(context.l10n.addFilter),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─────────────────────────────────────────────
                    // NOTIFICATIONS
                    // ─────────────────────────────────────────────
                    _SetupSection(
                      title: context.l10n.notifications,
                      description: context.l10n.notificationsDesc,
                      icon: Icons.notifications_outlined,
                      expanded: _expandedSection == 1,
                      onToggle: () => _toggleSection(1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  _notificationsEnabled
                                      ? Icons.check_circle
                                      : Icons.notifications_none,
                                  color: _notificationsEnabled
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _notificationsEnabled
                                        ? context.l10n.notificationsEnabled
                                        : context.l10n.notificationsNotEnabled,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_notificationsEnabled)
                            Icon(
                              Icons.check_rounded,
                              color: colorScheme.primary,
                            )
                          else
                            FilledButton.tonal(
                              onPressed: _notificationsLoading
                                  ? null
                                  : _setupNotifications,
                              child: _notificationsLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(context.l10n.enable),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─────────────────────────────────────────────
                    // APPEARANCE
                    // ─────────────────────────────────────────────
                    _SetupSection(
                      title: context.l10n.appearance,
                      description: context.l10n.appearanceDesc,
                      icon: Icons.palette_outlined,
                      expanded: _expandedSection == 2,
                      onToggle: () => _toggleSection(2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.appTheme,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),

                          const SizedBox(height: 8),

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
                            onSelectionChanged: (selection) {
                              if (selection.isNotEmpty) {
                                notifier.setTheme(selection.first);
                              }
                            },
                            style: SegmentedButton.styleFrom(
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              backgroundColor: Colors.transparent,
                              selectedBackgroundColor:
                                  colorScheme.primaryContainer,
                              selectedForegroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            context.l10n.darkTheme,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),

                          const SizedBox(height: 8),

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
                            onSelectionChanged: (selection) {
                              if (selection.isNotEmpty) {
                                notifier.setDarkTheme(selection.first);
                              }
                            },
                            style: SegmentedButton.styleFrom(
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              backgroundColor: Colors.transparent,
                              selectedBackgroundColor:
                                  colorScheme.primaryContainer,
                              selectedForegroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            context.l10n.themeColor,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: _ThemeChoice(
                                  title: context.l10n.defaultt,
                                  icon: Icons.palette_outlined,
                                  selected:
                                      settings.themeColor is StandardColor,
                                  onTap: () {
                                    notifier.setThemeColor(
                                      const StandardColor(),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: _ThemeChoice(
                                  title: context.l10n.dynamicc,
                                  icon: Icons.auto_awesome,
                                  selected: settings.themeColor is DynamicColor,
                                  onTap: () {
                                    notifier.setThemeColor(
                                      const DynamicColor(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

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
                                        (settings.themeColor as CustomColor)
                                                .color
                                                .toARGB32() ==
                                            color.toARGB32(),
                                    onTap: () {
                                      notifier.setThemeColor(
                                        CustomColor(color),
                                      );
                                    },
                                  ),
                                );
                              }
                              return Center(
                                child: _CustomColorButton(
                                  color: settings.themeColor is CustomColor
                                      ? (settings.themeColor as CustomColor)
                                            .color
                                      : null,
                                  selected:
                                      settings.themeColor is CustomColor &&
                                      !themeColors.any(
                                        (color) =>
                                            color.toARGB32() ==
                                            (settings.themeColor as CustomColor)
                                                .color
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

                    const SizedBox(height: 28),

                    FilledButton(
                      onPressed: widget.onComplete,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(
                        context.l10n.completeSetup,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      context.l10n.youCanChangeSettings,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SetupSection extends StatefulWidget {
  const _SetupSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
    required this.expanded,
    required this.onToggle,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget child;

  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<_SetupSection> createState() => _SetupSectionState();
}

class _SetupSectionState extends State<_SetupSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.expanded ? 1 : 0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SetupSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: widget.onToggle,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.icon,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizeTransition(
                            sizeFactor: _expandAnimation,
                            axis: Axis.vertical,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: Tween<double>(
                        begin: 0,
                        end: 0.5,
                      ).animate(_expandAnimation),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // The actual settings content smoothly expands/collapses.
            ClipRect(
              child: SizeTransition(
                sizeFactor: _expandAnimation,
                axis: Axis.vertical,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
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
