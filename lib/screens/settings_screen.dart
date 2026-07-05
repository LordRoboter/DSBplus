import 'package:flutter/material.dart';
import 'package:planner/services/data_repository.dart';

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
              ],
            ),
          ),
        );
      },
    );
  }
}
