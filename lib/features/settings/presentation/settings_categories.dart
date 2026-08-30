import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/timetables/model/filter.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/theme.dart';
import 'package:planner/features/settings/presentation/widgets/dialogues.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';

const nativeLanguageNames = {'de': 'Deutsch', 'en': 'English'};

class AuthSettingsPage extends ConsumerStatefulWidget {
  const AuthSettingsPage({super.key});

  @override
  ConsumerState<AuthSettingsPage> createState() => _AuthSettingsPageState();
}

class _AuthSettingsPageState extends ConsumerState<AuthSettingsPage> {
  final usernameController = TextEditingController();
  final usernameFocusNode = FocusNode();

  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();

  bool _loadingCredentials = true;
  bool _saving = false;

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = ref.read(authRepositoryProvider);

    final username = await credentials.getUsername();
    final password = await credentials.getPassword();

    if (!mounted) return;

    usernameController.text = username ?? '';
    passwordController.text = password ?? '';

    setState(() {
      _loadingCredentials = false;
    });
  }

  Future<void> _saveCredentials() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final credentials = ref.read(authRepositoryProvider);

      await credentials.saveCredentials(username: username, password: password);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.credentialsSaved)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    usernameFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCredentials) {
      return const Center(child: CircularProgressIndicator());
    }

    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        return SettingsPageScaffold(
          title: context.l10n.credentials,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: usernameController,
                      focusNode: usernameFocusNode,
                      decoration: InputDecoration(
                        labelText: context.l10n.username,
                        hintText: context.l10n.usernameHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        passwordFocusNode.requestFocus();
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: context.l10n.password,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          tooltip: _showPassword
                              ? context.l10n.hidePassword
                              : context.l10n.showPassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _saving ? null : _saveCredentials,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.save),
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

class FiltersSettingsPage extends ConsumerStatefulWidget {
  const FiltersSettingsPage({super.key});

  @override
  ConsumerState<FiltersSettingsPage> createState() =>
      _FiltersSettingsPageState();
}

class _FiltersSettingsPageState extends ConsumerState<FiltersSettingsPage> {
  final classController = TextEditingController();
  final classFocusNode = FocusNode();

  @override
  void dispose() {
    classController.dispose();
    classFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addClass() async {
    final className = classController.text.trim();

    if (className.isEmpty) {
      return;
    }

    final settings = ref.read(settingsProvider).requireValue;
    final notifier = ref.read(settingsProvider.notifier);

    final updatedClasses = {...settings.classFilter.classes, className};

    await notifier.setClassFilter(
      settings.classFilter.copyWith(classes: updatedClasses),
    );

    classController.clear();
  }

  Future<void> _removeClass(String className) async {
    final settings = ref.read(settingsProvider).requireValue;
    final notifier = ref.read(settingsProvider.notifier);

    final updatedClasses = {...settings.classFilter.classes}..remove(className);

    await notifier.setClassFilter(
      settings.classFilter.copyWith(classes: updatedClasses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        return SettingsPageScaffold(
          title: context.l10n.filter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: classController,
                      focusNode: classFocusNode,
                      decoration: InputDecoration(
                        labelText: context.l10n.classFilter,
                        hintText: context.l10n.classFilterHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.class_),
                        suffixIcon: classController.text.trim().isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addClass,
                              )
                            : null,
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
                        children: settings.classFilter.classes.map((className) {
                          return Chip(
                            label: Text(className),
                            onDeleted: () => _removeClass(className),
                            deleteIcon: const Icon(Icons.close),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SettingsSectionHeader(
                        title: context.l10n.advancedFilters,
                        action: TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const HelpDialog(),
                          ),
                          icon: const Icon(Icons.help_outline),
                          label: Text(context.l10n.help),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...settings.filters.map(
                      (filter) => SettingsFilterTile(
                        filter: filter,
                        onEdit: () async {
                          final updatedFilter =
                              await showDialog<TimetableFilter>(
                                context: context,
                                builder: (_) =>
                                    FilterDialog(initialFilter: filter),
                              );

                          if (updatedFilter != null) {
                            await ref
                                .read(settingsProvider.notifier)
                                .updateFilter(filter, updatedFilter);
                          }
                        },
                        onDelete: () => ref
                            .read(settingsProvider.notifier)
                            .removeFilter(filter),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final filter = await showDialog<TimetableFilter>(
                          context: context,
                          builder: (_) => const FilterDialog(),
                        );

                        if (filter != null) {
                          await ref
                              .read(settingsProvider.notifier)
                              .addFilter(filter);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.addFilter),
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

class CleanupSettingsPage extends ConsumerWidget {
  const CleanupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        final notifier = ref.read(settingsProvider.notifier);

        return SettingsPageScaffold(
          title: context.l10n.cleanup,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSwitchCard(
                title: context.l10n.simplifyEntries,
                subtitle: context.l10n.simplifyEntriesSub,
                value: settings.simplify,
                onChanged: notifier.setSimplify,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(context.l10n.cleanupEntries),
                      subtitle: Text(context.l10n.cleanupEntriesSub),
                      value: settings.clean,
                      onChanged: notifier.setClean,
                    ),
                    const Divider(height: 1),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: settings.clean ? 1 : 0.5,
                      child: IgnorePointer(
                        ignoring: !settings.clean,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(context.l10n.cleanupOptions),
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyClassNames),
                              value: settings.cleanClassNames,
                              onChanged: settings.clean
                                  ? notifier.setCleanClassNames
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyLessonStatus),
                              value: settings.remapTypes,
                              onChanged: settings.clean
                                  ? notifier.setRemapTypes
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyCourses),
                              value: settings.cleanupCourses,
                              onChanged: settings.clean
                                  ? notifier.setCleanupCourses
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.mergeTutorCourses),
                              value: settings.disposeTut,
                              onChanged: settings.clean
                                  ? notifier.setDisposeTut
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.renameSubjects),
                              value: settings.mapCourses,
                              onChanged:
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'de' &&
                                      settings.clean
                                  ? notifier.setMapCourses
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.removeCourseNumbers),
                              value: settings.disposeCourseNumbers,
                              onChanged: settings.clean
                                  ? notifier.setDisposeCourseNumbers
                                  : null,
                            ),
                          ],
                        ),
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

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        final notifier = ref.read(settingsProvider.notifier);

        return SettingsPageScaffold(
          title: context.l10n.notifications,
          child: Column(
            children: [
              SettingsSwitchCard(
                title: context.l10n.notifications,
                value: settings.notifications,
                onChanged: notifier.setNotifications,
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(context.l10n.firebase),
                      subtitle: Text(context.l10n.firebaseDesc),
                      value: settings.firebase,
                      onChanged: notifier.setFirebase,
                    ),
                    SwitchListTile(
                      title: Text(context.l10n.workManager),
                      subtitle: Text(context.l10n.workManagerDesc),
                      value: settings.workManager,
                      onChanged: notifier.setWorkManager,
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

class SettingsCategoriesPage extends StatelessWidget {
  const SettingsCategoriesPage({super.key});

  Widget _stackedCategories(List<SettingsCategoryTile> tiles) {
    final children = <Widget>[];

    for (var index = 0; index < tiles.length; index++) {
      children.add(tiles[index]);

      if (index != tiles.length - 1) {
        children.add(const SizedBox(height: 1));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _stackedCategories([
            SettingsCategoryTile(
              title: context.l10n.credentials,
              subtitle: context.l10n.credentialsExp,
              icon: Icons.account_circle,
              position: SettingsCategoryTilePosition.single,
              onTap: () => _open(context, const AuthSettingsPage()),
            ),
          ]),
          const SizedBox(height: 16),
          _stackedCategories([
            SettingsCategoryTile(
              title: context.l10n.language,
              subtitle: context.l10n.languageExp,
              icon: Icons.language_outlined,
              position: SettingsCategoryTilePosition.top,
              onTap: () => _open(context, const LanguageSettingsPage()),
            ),
            SettingsCategoryTile(
              title: context.l10n.appearance,
              subtitle: context.l10n.darkTheme,
              icon: Icons.palette_outlined,
              position: SettingsCategoryTilePosition.middle,
              onTap: () => _open(context, const AppearanceSettingsPage()),
            ),
            SettingsCategoryTile(
              title: context.l10n.notifications,
              subtitle: context.l10n.notificationsExp,
              icon: Icons.notifications_outlined,
              position: SettingsCategoryTilePosition.bottom,
              onTap: () => _open(context, const NotificationsSettingsPage()),
            ),
          ]),
          const SizedBox(height: 16),
          _stackedCategories([
            SettingsCategoryTile(
              title: context.l10n.cleanup,
              subtitle: context.l10n.enhanceEntries,
              icon: Icons.cleaning_services_outlined,
              position: SettingsCategoryTilePosition.top,
              onTap: () => _open(context, const CleanupSettingsPage()),
            ),
            SettingsCategoryTile(
              title: context.l10n.filters,
              subtitle: context.l10n.filtersExp,
              icon: Icons.filter_alt_outlined,
              position: SettingsCategoryTilePosition.bottom,
              onTap: () => _open(context, const FiltersSettingsPage()),
            ),
          ]),
        ],
      ),
    );
  }
}
