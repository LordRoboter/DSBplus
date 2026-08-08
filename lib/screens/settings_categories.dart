import 'package:flutter/material.dart';
import 'package:planner/core/models/filter.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/widgets/dialogues.dart';
import 'package:planner/widgets/settings.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/theme.dart';
import 'package:provider/provider.dart';

const nativeLanguageNames = {'de': 'Deutsch', 'en': 'English'};

class FiltersSettingsPage extends StatefulWidget {
  const FiltersSettingsPage({super.key});

  @override
  State<FiltersSettingsPage> createState() => _FiltersSettingsPageState();
}

class _FiltersSettingsPageState extends State<FiltersSettingsPage> {
  final classController = TextEditingController();
  final classFocusNode = FocusNode();
  late DataRepository data;

  final labels = {
    "class": "Klasse",
    "lesson": "Stunde",
    "subject": "Fach",
    "teacher": "Lehrer",
    "day": "Tag",
    "date": "Datum",
  };

  @override
  void initState() {
    super.initState();
    data = context.read<DataRepository>();
  }

  @override
  void dispose() {
    classController.dispose();
    classFocusNode.dispose();
    super.dispose();
  }

  void _addClass() {
    if (classController.text.isNotEmpty) {
      final updatedClasses = {
        ...data.classFilter.classes,
        classController.text,
      };
      data.setClassFilter(data.classFilter.copyWith(classes: updatedClasses));
      classController.clear();
      setState(() {});
    }
  }

  void _removeClass(String className) {
    final updatedClasses = {...data.classFilter.classes};
    updatedClasses.remove(className);
    data.setClassFilter(data.classFilter.copyWith(classes: updatedClasses));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataRepository>(
      builder: (context, data, _) {
        return SettingsPageScaffold(
          title: context.l10n.filter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input field
                    TextField(
                      controller: classController,
                      focusNode: classFocusNode,
                      decoration: InputDecoration(
                        labelText: context.l10n.classFilter,
                        hintText: context.l10n.classFilterHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.class_),
                        suffixIcon: classController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addClass,
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _addClass(),
                      onChanged: (value) {
                        setState(() {}); // Refresh to show/hide add button
                      },
                    ),
                    if (data.classFilter.classes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...data.classFilter.classes.map((className) {
                            return Chip(
                              label: Text(className),
                              onDeleted: () => _removeClass(className),
                              deleteIcon: const Icon(Icons.close),
                            );
                          }),
                        ],
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
                    ...data.filters.map(
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
                            data.updateFilter(filter, updatedFilter);
                          }
                        },
                        onDelete: () => data.removeFilter(filter),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final filter = await showDialog<TimetableFilter>(
                          context: context,
                          builder: (_) => const FilterDialog(),
                        );

                        if (filter != null) {
                          data.addFilter(filter);
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

class CleanupSettingsPage extends StatelessWidget {
  const CleanupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataRepository>(
      builder: (context, data, _) {
        return SettingsPageScaffold(
          title: context.l10n.cleanup,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSwitchCard(
                title: context.l10n.simplifyEntries,
                subtitle: context.l10n.simplifyEntriesSub,
                value: data.simplify,
                onChanged: data.setSimplify,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(context.l10n.cleanupEntries),
                      subtitle: Text(context.l10n.cleanupEntriesSub),
                      value: data.clean,
                      onChanged: data.setClean,
                    ),
                    const Divider(height: 1),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: data.clean ? 1 : 0.5,
                      child: IgnorePointer(
                        ignoring: !data.clean,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(context.l10n.cleanupOptions),
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyClassNames),
                              value: data.cleanClassNames,
                              onChanged: data.clean
                                  ? data.setCleanClassNames
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyLessonStatus),
                              value: data.remapTypes,
                              onChanged: data.clean ? data.setRemapTypes : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyCourses),
                              value: data.cleanupCourses,
                              onChanged: data.clean
                                  ? data.setCleanupCourses
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.mergeTutorCourses),
                              value: data.disposeTut,
                              onChanged: data.clean ? data.setDisposeTut : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.renameSubjects),
                              value: data.mapCourses,
                              onChanged: data.clean ? data.setMapCourses : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.removeCourseNumbers),
                              value: data.disposeCourseNumbers,
                              onChanged: data.clean
                                  ? data.setDisposeCourseNumbers
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

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataRepository>(
      builder: (context, data, _) {
        return SettingsPageScaffold(
          title: context.l10n.notifications,
          child: SettingsSwitchCard(
            title: context.l10n.notifications,
            value: data.notifications,
            onChanged: data.setNotifications,
          ),
        );
      },
    );
  }
}

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataRepository>(
      builder: (context, data, _) {
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
                    SettingsLabeledRow(
                      title: context.l10n.appTheme,
                      child: DropdownMenu<AppThemes>(
                        initialSelection: data.theme,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: AppThemes.system,
                            label: context.l10n.system,
                          ),
                          DropdownMenuEntry(
                            value: AppThemes.light,
                            label: context.l10n.light,
                          ),
                          DropdownMenuEntry(
                            value: AppThemes.dark,
                            label: context.l10n.dark,
                          ),
                        ],
                        onSelected: (value) {
                          if (value != null) {
                            data.setTheme(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingsLabeledRow(
                      title: context.l10n.darkTheme,
                      child: DropdownMenu<DarkTheme>(
                        initialSelection: data.darkTheme,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: DarkTheme.dark,
                            label: context.l10n.standard,
                          ),
                          DropdownMenuEntry(
                            value: DarkTheme.amoled,
                            label: context.l10n.amoled,
                          ),
                        ],
                        onSelected: (value) {
                          if (value != null) {
                            data.setDarkTheme(value);
                          }
                        },
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

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return Consumer<DataRepository>(
      builder: (context, data, _) {
        return SettingsPageScaffold(
          title: context.l10n.language,
          child: SettingsSectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsLabeledRow(
              title: context.l10n.language,
              child: DropdownMenu<Locale?>(
                initialSelection: data.locale,
                dropdownMenuEntries: [
                  DropdownMenuEntry<Locale?>(
                    value: null,
                    label:
                        '${context.l10n.systemDefault} (${nativeLanguageNames[systemLocale.languageCode] ?? 'English'})',
                  ),
                  DropdownMenuEntry<Locale?>(
                    value: Locale('en'),
                    label: context.l10n.english == 'English'
                        ? 'English'
                        : '${context.l10n.english} (English)',
                  ),
                  DropdownMenuEntry<Locale?>(
                    value: Locale('de'),
                    label: context.l10n.german == 'Deutsch'
                        ? 'Deutsch'
                        : '${context.l10n.german} (Deutsch)',
                  ),
                ],
                onSelected: data.setLocale,
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
