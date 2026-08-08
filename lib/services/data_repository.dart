import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/models/daydate.dart';
import 'package:planner/core/models/filter.dart';
import 'package:planner/core/models/timetable.dart';
import 'package:planner/services/dsb_api.dart';
import 'package:planner/theme.dart';
import 'package:planner/core/util/date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:collection/collection.dart';

class DataRepository extends ChangeNotifier {
  late final SharedPreferences prefs;

  Locale? locale;

  bool simplify = true;
  bool clean = true;

  bool disposeTut = true;
  bool cleanClassNames = true;
  bool remapTypes = true;
  bool cleanupCourses = true;
  bool disposeCourseNumbers = true;
  bool mapCourses = true;

  bool notifications = true;

  TimetableFilter classFilter = const TimetableFilter();
  List<TimetableFilter> filters = [];

  String lastUpdated = "";
  DayDate? selectedDayDate;

  List<Timetable> cachedEntries = [];

  final _updates = StreamController<void>.broadcast();

  AppThemes theme = AppThemes.system;
  DarkTheme darkTheme = DarkTheme.dark;

  Stream<void> get updates => _updates.stream;

  List<DayDate> get availableDayDates => cachedEntries
      .map((e) {
        return formatDayDate(e);
      })
      .toSet()
      .toList();

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    await loadSettings();
    await loadCache();
  }

  Locale? _parseLocale(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final parts = value.split('-');

    return Locale.fromSubtags(
      languageCode: parts[0],
      countryCode: parts.length > 1 ? parts[1] : null,
    );
  }

  Future<void> loadSettings() async {
    locale = _parseLocale(prefs.getString("locale"));

    clean = prefs.getBool("clean") ?? true;
    simplify = prefs.getBool("simplify") ?? true;

    disposeTut = prefs.getBool("disposeTut") ?? true;
    cleanClassNames = prefs.getBool("cleanClassNames") ?? true;
    remapTypes = prefs.getBool("remapTypes") ?? true;
    cleanupCourses = prefs.getBool("cleanupCourses") ?? true;
    disposeCourseNumbers = prefs.getBool("disposeCourseNumbers") ?? true;
    mapCourses = prefs.getBool("mapCourses") ?? true;

    loadTheme();
    loadDarkTheme();

    notifications = prefs.getBool("notifications") ?? true;

    final classJson = prefs.getString("classFilter");

    if (classJson != null) {
      classFilter = TimetableFilter.fromJson(jsonDecode(classJson));
    } else {
      classFilter = const TimetableFilter();
    }

    final filtersJson = prefs.getString("filters");

    if (filtersJson != null) {
      final decoded = jsonDecode(filtersJson) as List;

      filters =
          decoded
              .map(
                (e) => TimetableFilter.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
            ..sort();
    } else {
      filters = [];
    }

    final selected = prefs.getString("selectedDayDate");

    if (selected != null) {
      selectedDayDate = DayDate.fromJson(jsonDecode(selected));
    }

    notifyListeners();
  }

  Future<List<Timetable>> sync() async {
    final api = DSBApi(
      "REMOVED",
      "REMOVED",
      tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
    );

    final oldEntries = cachedEntries;
    final entries = await api.fetchEntries();

    const equality = DeepCollectionEquality();

    final changed = !equality.equals(
      oldEntries.map((e) => e.toJson()).toList(),
      entries.map((e) => e.toJson()).toList(),
    );

    await validateSelectedDayDate(
      entries
          .map((e) {
            return formatDayDate(e);
          })
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

  Future<void> setLocale(Locale? value) async {
    locale = value;

    if (value == null) {
      await prefs.remove("locale");
    } else {
      await prefs.setString("locale", value.toLanguageTag());
    }

    notifyListeners();
  }

  Future<void> setSelectedDayDate(DayDate dayDate) async {
    selectedDayDate = dayDate;

    await prefs.setString("selectedDayDate", jsonEncode(dayDate.toJson()));

    notifyListeners();
  }

  Future<void> validateSelectedDayDate(List<DayDate> dayDates) async {
    if (selectedDayDate == null || !dayDates.contains(selectedDayDate)) {
      selectedDayDate = dayDates.isNotEmpty ? dayDates.first : null;

      if (selectedDayDate != null) {
        await prefs.setString(
          "selectedDayDate",
          jsonEncode(selectedDayDate!.toJson()),
        );
      } else {
        await prefs.remove("selectedDayDate");
      }

      notifyListeners();
    }
  }

  int encodeDate(DateTime date) =>
      date.difference(DateTime.utc(1970, 1, 1)).inDays;

  DateTime decodeDate(int days) =>
      DateTime.utc(1970, 1, 1).add(Duration(days: days));

  Future<void> loadCache() async {
    lastUpdated = prefs.getString("updated") ?? "";

    final entriesJson = prefs.getString("entries");
    if (entriesJson != null) {
      final decoded = jsonDecode(entriesJson) as List;

      cachedEntries = decoded.map((e) => Timetable.fromJson(e)).toList();
    }
  }

  Future<void> saveEntries(List<Timetable> entries) async {
    cachedEntries = entries;

    final jsonEntries = entries.map((e) => e.toJson()).toList();

    await prefs.setString("entries", jsonEncode(jsonEntries));

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

  Future<void> setClassFilter(TimetableFilter value) async {
    classFilter = value;

    await prefs.setString("classFilter", jsonEncode(value.toJson()));

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

  Future<void> saveFilters() async {
    await prefs.setString(
      "filters",
      jsonEncode(filters.map((e) => e.toJson()).toList()),
    );

    notifyListeners();
  }

  Future<void> addFilter(TimetableFilter filter) async {
    filters.add(filter);

    await saveFilters();
  }

  Future<void> clearFilters() async {
    filters.clear();

    await prefs.remove("filters");
    notifyListeners();
  }

  Future<void> removeFilter(TimetableFilter filter) async {
    filters.remove(filter);
    await saveFilters();
  }

  void updateFilter(TimetableFilter oldFilter, TimetableFilter newFilter) {
    final index = filters.indexOf(oldFilter);

    if (index != -1) {
      filters[index] = newFilter;
      notifyListeners();
    }
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;

    await prefs.setBool("notifications", value);

    notifyListeners();
  }

  Future<void> setTheme(AppThemes value) async {
    theme = value;

    await prefs.setInt("theme", value.index);

    notifyListeners();
  }

  void loadTheme() {
    final themeIndex = prefs.getInt("theme");

    if (themeIndex != null) {
      theme = AppThemes.values[themeIndex];
    }
  }

  Future<void> setDarkTheme(DarkTheme value) async {
    darkTheme = value;

    await prefs.setInt("darkTheme", value.index);

    notifyListeners();
  }

  void loadDarkTheme() {
    final themeIndex = prefs.getInt("darkTheme");

    if (themeIndex != null) {
      darkTheme = DarkTheme.values[themeIndex];
    }
  }
}
