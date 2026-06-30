import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dsb_api.dart';
import '../util/sorter.dart';

class PlanRepository extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> entries = {};
  Map<String, Map<String, List<Map<String, dynamic>>>> groupedEntries = {};

  bool loading = true;
  String? error;
  String? selectedDay;
  List<String> availableDays = [];

  bool ssimplify = true;
  bool ggroup = true;

  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await loadData();
  }

  Future<void> loadData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final simplify = prefs.getBool("simplify") ?? true;
      final group = prefs.getBool("group") ?? true;
      final clean = prefs.getBool("clean") ?? true;

      final api = DSBApi(
        "166162",
        "20Bueffel21",
        tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
      );

      final result = await api.fetchEntries();
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

      entries = dayResult;
      groupedEntries = groupedByDay;
      availableDays = days;

      selectedDay ??= days.isNotEmpty ? days.first : null;

      ssimplify = simplify;
      ggroup = group;

      loading = false;
      error = null;
      notifyListeners();
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
