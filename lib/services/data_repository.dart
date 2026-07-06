import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/services/dsb_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:collection/collection.dart';

class DataRepository extends ChangeNotifier {
  late final SharedPreferences prefs;

  bool simplify = true;
  bool clean = true;

  bool disposeTut = true;
  bool cleanClassNames = true;
  bool remapTypes = true;
  bool cleanupCourses = true;
  bool disposeCourseNumbers = true;
  bool mapCourses = true;

  String classFilter = "";

  String lastUpdated = "";
  String? selectedDayDate;

  List<Map<String, dynamic>> cachedEntries = [];

  final _updates = StreamController<void>.broadcast();

  Stream<void> get updates => _updates.stream;

  List<String> get availableDayDates => cachedEntries
      .map(
        (e) =>
            "${e["day"] as String? ?? "Unknown"} (${e["date"] as String? ?? "Unknown"})",
      )
      .toSet()
      .toList();

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

    disposeTut = prefs.getBool("disposeTut") ?? true;
    cleanClassNames = prefs.getBool("cleanClassNames") ?? true;
    remapTypes = prefs.getBool("remapTypes") ?? true;
    cleanupCourses = prefs.getBool("cleanupCourses") ?? true;
    disposeCourseNumbers = prefs.getBool("disposeCourseNumbers") ?? true;
    mapCourses = prefs.getBool("mapCourses") ?? true;

    classFilter = prefs.getString("classFilter") ?? "";
    selectedDayDate = prefs.getString("selectedDayDate");

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

    final changed = !const DeepCollectionEquality().equals(oldEntries, entries);

    await validateSelectedDayDate(
      entries
          .map(
            (e) =>
                "${e["day"] as String? ?? "Unknown"} (${e["date"] as String? ?? "Unknown"})",
          )
          .toSet()
          .toList(),
    );

    await saveEntries(entries);

    if (changed) {
      _updates.add(null);
    }

    await saveUpdated(
      DateFormat('dd.MM. HH:mm', 'de_DE').format(DateTime.now()),
    );

    return oldEntries;
  }

  Future<void> setSelectedDayDate(String dayDate) async {
    selectedDayDate = dayDate;

    await prefs.setString("selectedDayDate", dayDate);

    notifyListeners();
  }

  Future<void> validateSelectedDayDate(List<String> dayDates) async {
    if (selectedDayDate == null || !dayDates.contains(selectedDayDate)) {
      selectedDayDate = dayDates.isNotEmpty ? dayDates.first : null;

      if (selectedDayDate != null) {
        await prefs.setString("selectedDayDate", selectedDayDate!);
      } else {
        await prefs.remove("selectedDayDate");
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

  Future<void> setDisposeTut(bool value) async {
    disposeTut = value;

    await prefs.setBool("disposeTut", value);

    notifyListeners();
  }

  Future<void> setCleanClassNames(bool value) async {
    cleanClassNames = value;

    await prefs.setBool("cleanClassNames", value);

    notifyListeners();
  }

  Future<void> setRemapTypes(bool value) async {
    remapTypes = value;

    await prefs.setBool("remapTypes", value);

    notifyListeners();
  }

  Future<void> setCleanupCourses(bool value) async {
    cleanupCourses = value;

    await prefs.setBool("cleanupCourses", value);

    notifyListeners();
  }

  Future<void> setDisposeCourseNumbers(bool value) async {
    disposeCourseNumbers = value;

    await prefs.setBool("disposeCourseNumbers", value);

    notifyListeners();
  }

  Future<void> setMapCourses(bool value) async {
    mapCourses = value;

    await prefs.setBool("mapCourses", value);

    notifyListeners();
  }
}
