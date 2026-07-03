import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/services/dsb_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataRepository extends ChangeNotifier {
  late final SharedPreferences prefs;

  bool simplify = true;
  bool clean = true;

  String lastUpdated = "";
  String classFilter = "";

  String? selectedDay;

  List<Map<String, dynamic>> cachedEntries = [];

  List<String> get availableDays =>
      cachedEntries.map((e) => e["day"] as String).toSet().toList();

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    loadSettings();
    loadCache();
  }

  Future<void> loadSettings() async {
    clean = prefs.getBool("clean") ?? true;
    simplify = prefs.getBool("simplify") ?? true;
    classFilter = prefs.getString("classFilter") ?? "";
    selectedDay = prefs.getString("selectedDay");

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> sync() async {
    final api = DSBApi(
      "REMOVED",
      "REMOVED",
      tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
    );

    final oldEntries = cachedEntries;
    final entries = await api.fetchEntries();

    await validateSelectedDay(
      entries.map((e) => e["day"] as String).toSet().toList(),
    );

    await saveEntries(entries);

    await saveUpdated(
      DateFormat('dd.MM. HH:mm', 'de_DE').format(DateTime.now()),
    );

    return oldEntries;
  }

  Future<void> setSelectedDay(String day) async {
    selectedDay = day;

    await prefs.setString("selectedDay", day);

    notifyListeners();
  }

  Future<void> validateSelectedDay(List<String> days) async {
    if (selectedDay == null || !days.contains(selectedDay)) {
      selectedDay = days.isNotEmpty ? days.first : null;

      if (selectedDay != null) {
        await prefs.setString("selectedDay", selectedDay!);
      } else {
        await prefs.remove("selectedDay");
      }

      notifyListeners();
    }
  }

  Future<void> loadCache() async {
    lastUpdated = prefs.getString("updated") ?? "";

    final entriesJson = prefs.getString("entries");
    if (entriesJson != null) {
      final decoded = jsonDecode(entriesJson) as List;
      cachedEntries = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  Future<void> saveEntries(List<Map<String, dynamic>> entries) async {
    cachedEntries = entries;

    await prefs.setString("entries", jsonEncode(entries));

    notifyListeners();
  }

  Future<void> saveUpdated(String value) async {
    lastUpdated = value;

    await prefs.setString("updated", value);

    notifyListeners();
  }

  Future<void> setClean(bool value) async {
    clean = value;

    await prefs.setBool("clean", value);

    notifyListeners();
  }

  Future<void> setSimplify(bool value) async {
    simplify = value;

    await prefs.setBool("simplify", value);

    notifyListeners();
  }

  Future<void> setClassFilter(String value) async {
    classFilter = value;

    await prefs.setString("classFilter", value);

    notifyListeners();
  }
}
