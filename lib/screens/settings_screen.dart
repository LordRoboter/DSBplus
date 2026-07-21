import 'package:flutter/material.dart';
import 'package:planner/components/dialogues.dart';
import 'package:planner/res/maps.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/theme.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataRepository>(
      builder: (context, data, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(title: const Text("Einstellungen")),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: classController,
                      focusNode: classFocusNode,
                      decoration: const InputDecoration(
                        labelText: "Klassenfilter",
                        hintText: "z.B. 10a (Mehrere Klassen möglich)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text("Benachrichtigungen"),
                        value: data.notifications,
                        onChanged: data.setNotifications,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text("Einträge vereinfachen"),
                        subtitle: const Text(
                          "Gedoppelte Einträge zusammenfassen",
                        ),
                        value: data.simplify,
                        onChanged: data.setSimplify,
                      ),
                    ],
                  ),
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  4,
                                ),
                                child: Text(
                                  "Bereinigungsoptionen",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),

                              SwitchListTile(
                                title: const Text("Klassennamen vereinfachen"),
                                value: data.cleanClassNames,
                                onChanged: data.clean
                                    ? data.setCleanClassNames
                                    : null,
                              ),

                              SwitchListTile(
                                title: const Text(
                                  "Unterrichtsstatus vereinfachen",
                                ),
                                value: data.remapTypes,
                                onChanged: data.clean
                                    ? data.setRemapTypes
                                    : null,
                              ),

                              SwitchListTile(
                                title: const Text("Kurse vereinfachen"),
                                value: data.cleanupCourses,
                                onChanged: data.clean
                                    ? data.setCleanupCourses
                                    : null,
                              ),

                              SwitchListTile(
                                title: const Text(
                                  "Tutorenkurse zusammenfassen",
                                ),
                                value: data.disposeTut,
                                onChanged: data.clean
                                    ? data.setDisposeTut
                                    : null,
                              ),

                              SwitchListTile(
                                title: const Text("Fächer umbenennen"),
                                value: data.mapCourses,
                                onChanged: data.clean
                                    ? data.setMapCourses
                                    : null,
                              ),

                              SwitchListTile(
                                title: const Text("Kursnummern entfernen"),
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

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Erweiterte Filter",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => const HelpDialog(),
                                ),
                                icon: const Icon(Icons.help_outline),
                                label: const Text("Hilfe"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...data.filters.map((filter) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                filter.entries
                                    .map(
                                      (e) =>
                                          "${labels[e.key] ?? e.key}: ${e.value}",
                                    )
                                    .join(" • "),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        final updatedFilter =
                                            await showDialog<
                                              Map<String, String>
                                            >(
                                              context: context,
                                              builder: (_) => FilterDialog(
                                                initialFilter: filter,
                                              ),
                                            );

                                        if (updatedFilter != null &&
                                            updatedFilter.isNotEmpty) {
                                          data.updateFilter(
                                            filter,
                                            updatedFilter,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          data.removeFilter(filter),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        FilledButton.icon(
                          onPressed: () async {
                            final filter =
                                await showDialog<Map<String, String>>(
                                  context: context,
                                  builder: (_) => const FilterDialog(),
                                );

                            if (filter != null && filter.isNotEmpty) {
                              data.addFilter(filter);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Filter hinzufügen"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "App Thema",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownMenu<AppThemes>(
                          initialSelection: data.theme,
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                              value: AppThemes.system,
                              label: "System",
                            ),
                            DropdownMenuEntry(
                              value: AppThemes.light,
                              label: "Light",
                            ),
                            DropdownMenuEntry(
                              value: AppThemes.dark,
                              label: "Dark",
                            ),
                          ],
                          onSelected: (value) {
                            if (value != null) {
                              data.setTheme(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
