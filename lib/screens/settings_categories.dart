import 'package:flutter/material.dart';
import 'package:planner/components/dialogues.dart';
import 'package:planner/components/settings.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/theme.dart';
import 'package:provider/provider.dart';

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
    classController.text = data.classFilter;

    classFocusNode.addListener(() {
      if (!classFocusNode.hasFocus &&
          classController.text != data.classFilter) {
        data.setClassFilter(classController.text);
      }
    });
  }

  @override
  void dispose() {
    classController.dispose();
    classFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataRepository>(
      builder: (context, data, _) {
        return SettingsPageScaffold(
          title: 'Filter',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                child: TextField(
                  controller: classController,
                  focusNode: classFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Klassenfilter',
                    hintText: 'z.B. 10a (Mehrere Klassen möglich)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_),
                  ),
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
                        title: 'Erweiterte Filter',
                        action: TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const HelpDialog(),
                          ),
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Hilfe'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...data.filters.map(
                      (filter) => SettingsFilterTile(
                        filter: filter,
                        labels: labels,
                        onEdit: () async {
                          final updatedFilter =
                              await showDialog<Map<String, String>>(
                                context: context,
                                builder: (_) =>
                                    FilterDialog(initialFilter: filter),
                              );

                          if (updatedFilter != null &&
                              updatedFilter.isNotEmpty) {
                            data.updateFilter(filter, updatedFilter);
                          }
                        },
                        onDelete: () => data.removeFilter(filter),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final filter = await showDialog<Map<String, String>>(
                          context: context,
                          builder: (_) => const FilterDialog(),
                        );

                        if (filter != null && filter.isNotEmpty) {
                          data.addFilter(filter);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Filter hinzufügen'),
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
          title: 'Cleanup',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSwitchCard(
                title: 'Einträge vereinfachen',
                subtitle: 'Gedoppelte Einträge zusammenfassen',
                value: data.simplify,
                onChanged: data.setSimplify,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text("Einträge bereinigen"),
                      subtitle: const Text("Einträge besser lesbar machen"),
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
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text('Bereinigungsoptionen'),
                            ),
                            SwitchListTile(
                              title: const Text('Klassennamen vereinfachen'),
                              value: data.cleanClassNames,
                              onChanged: data.clean
                                  ? data.setCleanClassNames
                                  : null,
                            ),
                            SwitchListTile(
                              title: const Text(
                                'Unterrichtsstatus vereinfachen',
                              ),
                              value: data.remapTypes,
                              onChanged: data.clean ? data.setRemapTypes : null,
                            ),
                            SwitchListTile(
                              title: const Text('Kurse vereinfachen'),
                              value: data.cleanupCourses,
                              onChanged: data.clean
                                  ? data.setCleanupCourses
                                  : null,
                            ),
                            SwitchListTile(
                              title: const Text('Tutorenkurse zusammenfassen'),
                              value: data.disposeTut,
                              onChanged: data.clean ? data.setDisposeTut : null,
                            ),
                            SwitchListTile(
                              title: const Text('Fächer umbenennen'),
                              value: data.mapCourses,
                              onChanged: data.clean ? data.setMapCourses : null,
                            ),
                            SwitchListTile(
                              title: const Text('Kursnummern entfernen'),
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
          title: 'Benachrichtigungen',
          child: SettingsSwitchCard(
            title: 'Benachrichtigungen',
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
          title: 'Aussehen',
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
                      title: 'App Thema',
                      child: DropdownMenu<AppThemes>(
                        initialSelection: data.theme,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: AppThemes.system,
                            label: 'System',
                          ),
                          DropdownMenuEntry(
                            value: AppThemes.light,
                            label: 'Light',
                          ),
                          DropdownMenuEntry(
                            value: AppThemes.dark,
                            label: 'Dark',
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
                      title: 'Dunkles Thema',
                      child: DropdownMenu<DarkTheme>(
                        initialSelection: data.darkTheme,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: DarkTheme.dark,
                            label: 'Standard',
                          ),
                          DropdownMenuEntry(
                            value: DarkTheme.amoled,
                            label: 'Amoled',
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
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _stackedCategories([
            SettingsCategoryTile(
              title: 'Aussehen',
              subtitle: 'Theme und dunkles Thema',
              icon: Icons.palette_outlined,
              position: SettingsCategoryTilePosition.top,
              onTap: () => _open(context, const AppearanceSettingsPage()),
            ),
            SettingsCategoryTile(
              title: 'Benachrichtigungen',
              subtitle: 'Push-Benachrichtigungen für Planänderungen',
              icon: Icons.notifications_outlined,
              position: SettingsCategoryTilePosition.bottom,
              onTap: () => _open(context, const NotificationsSettingsPage()),
            ),
          ]),
          const SizedBox(height: 16),
          _stackedCategories([
            SettingsCategoryTile(
              title: 'Cleanup',
              subtitle: 'Bereinigung und Normalisierung',
              icon: Icons.cleaning_services_outlined,
              position: SettingsCategoryTilePosition.top,
              onTap: () => _open(context, const CleanupSettingsPage()),
            ),
            SettingsCategoryTile(
              title: 'Filter',
              subtitle: 'Klassenfilter und erweiterte Filter',
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
