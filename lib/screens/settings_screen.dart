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
  late DataRepository data;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    data = context.read<DataRepository>();
    classController.text = data.classFilter;
  }

  @override
  void dispose() {
    classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          TextFormField(
            controller: classController,
            decoration: const InputDecoration(labelText: "Class"),
            onFieldSubmitted: (value) async {
              data.setClassFilter(value);
            },
          ),
        ],
      ),
    );
  }
}
