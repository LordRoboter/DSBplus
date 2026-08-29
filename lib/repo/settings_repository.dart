/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planner/core/model/daydate.dart';
import 'package:planner/core/model/filter.dart';
import 'package:planner/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class SettingsRepository extends ChangeNotifier {
  late final SharedPreferences prefs;

  Locale? locale;
  DayDate? selectedDayDate;

  bool clean = false;
  bool simplify = false;
  bool disposeTut = false;
  bool cleanClassNames = false;
  bool remapTypes = false;
  bool cleanupCourses = false;
  bool disposeCourseNumbers = false;
  bool mapCourses = false;

  bool notifications = false;
  bool firebase = false;
  bool workManager = false;

  List<TimetableFilter> filters = [];
  TimetableFilter classFilter = TimetableFilter();

  AppThemes theme = AppThemes.system;
  DarkTheme darkTheme = DarkTheme.dark;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    locale = _loadLocale();
    selectedDayDate = _loadSelectedDayDate();

    clean = prefs.getBool('clean') ?? false;
    simplify = prefs.getBool('simplify') ?? false;
    disposeTut = prefs.getBool('disposeTut') ?? false;
    cleanClassNames = prefs.getBool('cleanClassNames') ?? false;
    remapTypes = prefs.getBool('remapTypes') ?? false;
    cleanupCourses = prefs.getBool('cleanupCourses') ?? false;
    disposeCourseNumbers = prefs.getBool('disposeCourseNumbers') ?? false;
    mapCourses = prefs.getBool('mapCourses') ?? false;

    notifications = prefs.getBool('notifications') ?? false;
    firebase = prefs.getBool('firebase') ?? false;
    workManager = prefs.getBool('workManager') ?? false;

    filters = _loadFilters();
    classFilter = _loadClassFilter();

    _loadTheme();
    _loadDarkTheme();
  }

  Locale? _loadLocale() {
    final value = prefs.getString('locale');

    if (value == null) {
      return null;
    }

    return Locale.fromSubtags(languageCode: value.split('-').first);
  }

  DayDate? _loadSelectedDayDate() {
    final value = prefs.getString('selectedDayDate');

    if (value == null) {
      return null;
    }

    return DayDate.fromJson(jsonDecode(value));
  }

  List<TimetableFilter> _loadFilters() {
    final value = prefs.getString('filters');

    if (value == null) {
      return [];
    }

    final decoded = jsonDecode(value) as List;

    return decoded.map((e) => TimetableFilter.fromJson(e)).toList();
  }

  TimetableFilter _loadClassFilter() {
    final classJson = prefs.getString("classFilter");

    if (classJson != null) {
      return TimetableFilter.fromJson(jsonDecode(classJson));
    } else {
      return const TimetableFilter();
    }
  }

  void _loadTheme() {
    final index = prefs.getInt('theme');

    if (index != null && index >= 0 && index < AppThemes.values.length) {
      theme = AppThemes.values[index];
    }
  }

  void _loadDarkTheme() {
    final index = prefs.getInt('darkTheme');

    if (index != null && index >= 0 && index < DarkTheme.values.length) {
      darkTheme = DarkTheme.values[index];
    }
  }

  Future<void> setLocale(Locale? value) async {
    locale = value;

    if (value == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', value.toLanguageTag());
    }

    notifyListeners();
  }

  Future<void> setSelectedDayDate(DayDate? value) async {
    selectedDayDate = value;

    if (value == null) {
      await prefs.remove('selectedDayDate');
    } else {
      await prefs.setString('selectedDayDate', jsonEncode(value.toJson()));
    }

    notifyListeners();
  }

  Future<void> setClean(bool value) async {
    clean = value;
    await prefs.setBool('clean', value);
    notifyListeners();
  }

  Future<void> setSimplify(bool value) async {
    simplify = value;
    await prefs.setBool('simplify', value);
    notifyListeners();
  }

  Future<void> setDisposeTut(bool value) async {
    disposeTut = value;
    await prefs.setBool('disposeTut', value);
    notifyListeners();
  }

  Future<void> setCleanClassNames(bool value) async {
    cleanClassNames = value;
    await prefs.setBool('cleanClassNames', value);
    notifyListeners();
  }

  Future<void> setRemapTypes(bool value) async {
    remapTypes = value;
    await prefs.setBool('remapTypes', value);
    notifyListeners();
  }

  Future<void> setCleanupCourses(bool value) async {
    cleanupCourses = value;
    await prefs.setBool('cleanupCourses', value);
    notifyListeners();
  }

  Future<void> setDisposeCourseNumbers(bool value) async {
    disposeCourseNumbers = value;
    await prefs.setBool('disposeCourseNumbers', value);
    notifyListeners();
  }

  Future<void> setMapCourses(bool value) async {
    mapCourses = value;
    await prefs.setBool('mapCourses', value);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;
    await prefs.setBool('notifications', value);
    notifyListeners();
  }

  Future<void> setFirebase(bool value) async {
    firebase = value;
    await prefs.setBool('firebase', value);
    notifyListeners();
  }

  Future<void> setWorkManager(bool value) async {
    workManager = value;

    if (value) {
      await Workmanager().registerPeriodicTask(
        'timetable-check',
        'timetableCheck',
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } else {
      await Workmanager().cancelByUniqueName('timetable-check');
    }

    await prefs.setBool('workManager', value);
    notifyListeners();
  }

  Future<void> setTheme(AppThemes value) async {
    theme = value;
    await prefs.setInt('theme', value.index);
    notifyListeners();
  }

  Future<void> setDarkTheme(DarkTheme value) async {
    darkTheme = value;
    await prefs.setInt('darkTheme', value.index);
    notifyListeners();
  }

  Future<void> setClassFilter(TimetableFilter value) async {
    classFilter = value;

    await prefs.setString("classFilter", jsonEncode(value.toJson()));

    notifyListeners();
  }

  Future<void> saveFilters() async {
    await prefs.setString(
      'filters',
      jsonEncode(filters.map((e) => e.toJson()).toList()),
    );

    notifyListeners();
  }

  Future<void> addFilter(TimetableFilter filter) async {
    filters.add(filter);
    await saveFilters();
  }

  Future<void> removeFilter(TimetableFilter filter) async {
    filters.remove(filter);
    await saveFilters();
  }

  Future<void> clearFilters() async {
    filters.clear();
    await prefs.remove('filters');
    notifyListeners();
  }

  Future<void> updateFilter(
    TimetableFilter oldFilter,
    TimetableFilter newFilter,
  ) async {
    final index = filters.indexOf(oldFilter);

    if (index == -1) {
      return;
    }

    filters[index] = newFilter;
    await saveFilters();
  }
}
*/
