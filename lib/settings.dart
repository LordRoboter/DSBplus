import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final classController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    classController.text = prefs.getString("class") ?? "";
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
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("class", value);
            },
          ),
        ],
      ),
    );
  }
}
