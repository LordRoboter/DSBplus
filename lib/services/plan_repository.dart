import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'dsb_api.dart';
import '../util/sorter.dart';

class PlanRepository extends ChangeNotifier {
  Map<String, Map<String, List<Map<String, dynamic>>>> groupedEntries = {};
  List<Map<String, dynamic>> entries = [];

  bool loading = true;
  String? error;
  String? selectedDay;
  List<String> availableDays = [];

  bool simplify = true;
  bool clean = true;

  String lastUpdated = "";
  String classFilter = "";

  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    reloadSettings();
    await loadData();
  }

  Future<void> reloadSettings() async {
    clean = prefs.getBool("clean") ?? true;
    simplify = prefs.getBool("simplify") ?? true;
    classFilter = prefs.getString("classFilter") ?? "";
    lastUpdated = prefs.getString("updated") ?? "";

    availableDays = prefs.getStringList("availableDays") ?? [];
    selectedDay = prefs.getString("selectedDay");

    final groupedJson = prefs.getString("groupedEntries");
    if (groupedJson != null) {
      final decoded = jsonDecode(groupedJson) as Map<String, dynamic>;

      groupedEntries = decoded.map(
        (day, classes) => MapEntry(
          day,
          (classes as Map<String, dynamic>).map(
            (clazz, entries) => MapEntry(
              clazz,
              (entries as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            ),
          ),
        ),
      );
    }

    final entriesJson = prefs.getString("entries");

    if (entriesJson != null) {
      final decoded = jsonDecode(entriesJson) as List;

      entries = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    notifyListeners();
  }

  Future<void> loadData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final api = DSBApi(
        "REMOVED",
        "REMOVED",
        tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
      );

      final result = await api.fetchEntries();
      entries = result;
      final dayResult = groupEntriesByDay(result);

      final days = result.map((e) => e["day"] as String).toSet().toList();

      final groupedByDay = <String, Map<String, List<Map<String, dynamic>>>>{};

      for (final entry in dayResult.entries) {
        var res = entry.value;

        if (clean) {
          res = cleanupEntries(res);
        }

        if (simplify) {
          res = simplifyEntries(res);
        }

        groupedByDay[entry.key] = groupEntries(res);
      }

      groupedEntries = groupedByDay;
      availableDays = days;

      selectedDay ??= days.isNotEmpty ? days.first : null;

      loading = false;
      error = null;
      lastUpdated = DateFormat('dd.MM. HH:mm', 'de_DE').format(DateTime.now());
      notifyListeners();

      prefs.setString("updated", lastUpdated);

      await prefs.setString("groupedEntries", jsonEncode(groupedEntries));
      await prefs.setString("entries", jsonEncode(entries));
      await prefs.setStringList("availableDays", availableDays);
      if (selectedDay != null) {
        await prefs.setString("selectedDay", selectedDay!);
      }
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }

  void selectDay(String day) {
    selectedDay = day;
    notifyListeners();
  }
}
