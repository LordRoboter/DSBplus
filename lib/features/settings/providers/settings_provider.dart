import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/notifications/background_tasks.dart';
import 'package:planner/features/notifications/model/interval.dart';
//import 'package:planner/core/model/daydate.dart';
import 'package:planner/features/timetables/model/filter.dart';
import 'package:planner/features/settings/model/settings_state.dart';
import 'package:planner/core/providers/shared_preferences_provider.dart';
import 'package:planner/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late SharedPreferences prefs;

  @override
  Future<SettingsState> build() async {
    prefs = ref.read(sharedPreferencesProvider);

    return SettingsState(
      startupComplete: prefs.getBool('startupComplete') ?? false,
      locale: _loadLocale(),
      //selectedDayDate: _loadSelectedDayDate(),
      clean: prefs.getBool('clean') ?? true,
      simplify: prefs.getBool('simplify') ?? true,
      disposeTut: prefs.getBool('disposeTut') ?? true,
      cleanClassNames: prefs.getBool('cleanClassNames') ?? true,
      remapTypes: prefs.getBool('remapTypes') ?? true,
      cleanupCourses: prefs.getBool('cleanupCourses') ?? true,
      disposeCourseNumbers: prefs.getBool('disposeCourseNumbers') ?? true,
      mapCourses: prefs.getBool('mapCourses') ?? true,
      collapse: prefs.getBool('collapse') ?? true,
      notifications: prefs.getBool('notifications') ?? true,
      firebase: prefs.getBool('firebase') ?? true,
      classFilter: _loadClassFilter(),
      workManager: prefs.getBool('workManager') ?? true,
      backgroundSchedule: _loadBackgroundSchedule(),
      filters: _loadFilters(),
      theme: _loadTheme(),
      darkTheme: _loadDarkTheme(),
      themeColor: _loadThemeColor(),
    );
  }

  // LOADING VALUES

  Locale? _loadLocale() {
    final value = prefs.getString('locale');

    if (value == null) {
      return null;
    }

    return Locale.fromSubtags(languageCode: value.split('-').first);
  }

  TimetableFilter _loadClassFilter() {
    final classJson = prefs.getString("classFilter");

    if (classJson != null) {
      return TimetableFilter.fromJson(jsonDecode(classJson));
    } else {
      return const TimetableFilter();
    }
  }

  /*DayDate? _loadSelectedDayDate() {
    final value = prefs.getString('selectedDayDate');

    if (value == null) {
      return null;
    }

    return DayDate.fromJson(jsonDecode(value));
  }*/

  List<TimetableFilter> _loadFilters() {
    final value = prefs.getString('filters');

    if (value == null) {
      return [];
    }

    final decoded = jsonDecode(value) as List;

    return decoded.map((e) => TimetableFilter.fromJson(e)).toList();
  }

  AppThemes _loadTheme() {
    final index = prefs.getInt('theme');

    return (index != null && index >= 0 && index < AppThemes.values.length)
        ? AppThemes.values[index]
        : AppThemes.system;
  }

  DarkTheme _loadDarkTheme() {
    final index = prefs.getInt('darkTheme');
    return (index != null && index >= 0 && index < DarkTheme.values.length)
        ? DarkTheme.values[index]
        : DarkTheme.dark;
  }

  Color? _loadThemeColor() {
    final value = prefs.getInt('themeColor');

    return value != null ? Color(value) : null;
  }

  BackgroundCheckSchedule _loadBackgroundSchedule() {
    final value = prefs.getString('backgroundSchedule');

    if (value == null) {
      return const BackgroundCheckSchedule();
    }

    try {
      final json = jsonDecode(value) as Map<String, dynamic>;

      return BackgroundCheckSchedule.fromJson(json);
    } catch (_) {
      return const BackgroundCheckSchedule();
    }
  }

  Future<void> setStartupComplete(bool value) async {
    _updateState((state) => state.copyWith(startupComplete: value));
    await prefs.setBool('startupComplete', value);
  }

  Future<void> setLocale(Locale? value) async {
    _updateState((state) => state.copyWith(locale: value));
    if (value == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', value.toLanguageTag());
    }
  }

  Future<void> setClean(bool value) async {
    _updateState((state) => state.copyWith(clean: value));
    await prefs.setBool('clean', value);
  }

  Future<void> setSimplify(bool value) async {
    _updateState((state) => state.copyWith(simplify: value));
    await prefs.setBool('simplify', value);
  }

  Future<void> setDisposeTut(bool value) async {
    _updateState((state) => state.copyWith(disposeTut: value));
    await prefs.setBool('disposeTut', value);
  }

  Future<void> setCleanClassNames(bool value) async {
    _updateState((state) => state.copyWith(cleanClassNames: value));
    await prefs.setBool('cleanClassNames', value);
  }

  Future<void> setRemapTypes(bool value) async {
    _updateState((state) => state.copyWith(remapTypes: value));
    await prefs.setBool('remapTypes', value);
  }

  Future<void> setCleanupCourses(bool value) async {
    _updateState((state) => state.copyWith(cleanupCourses: value));
    await prefs.setBool('cleanupCourses', value);
  }

  Future<void> setDisposeCourseNumbers(bool value) async {
    _updateState((state) => state.copyWith(disposeCourseNumbers: value));
    await prefs.setBool('disposeCourseNumbers', value);
  }

  Future<void> setMapCourses(bool value) async {
    _updateState((state) => state.copyWith(mapCourses: value));
    await prefs.setBool('mapCourses', value);
  }

  Future<void> setCollapse(bool value) async {
    _updateState((state) => state.copyWith(collapse: value));
    await prefs.setBool('collapse', value);
  }

  Future<void> setClassFilter(TimetableFilter value) async {
    _updateState((state) => state.copyWith(classFilter: value));
    await prefs.setString('classFilter', jsonEncode(value.toJson()));
  }

  Future<void> addFilter(TimetableFilter filter) async {
    _updateState(
      (state) => state.copyWith(filters: [...state.filters, filter]),
    );
    await _saveFilters();
  }

  Future<void> removeFilter(TimetableFilter filter) async {
    _updateState(
      (state) => state.copyWith(
        filters: state.filters.where((existing) => existing != filter).toList(),
      ),
    );
    await _saveFilters();
  }

  Future<void> updateFilter(
    TimetableFilter oldFilter,
    TimetableFilter newFilter,
  ) async {
    final current = state.requireValue;
    final index = current.filters.indexOf(oldFilter);
    if (index == -1) {
      return;
    }
    final filters = [...current.filters];
    filters[index] = newFilter;
    _updateState((_) => current.copyWith(filters: filters));
    await _saveFilters();
  }

  Future<void> clearFilters() async {
    _updateState((state) => state.copyWith(filters: []));
    await prefs.remove('filters');
  }

  Future<void> _saveFilters() async {
    final filters = state.requireValue.filters;
    await prefs.setString(
      'filters',
      jsonEncode(filters.map((filter) => filter.toJson()).toList()),
    );
  }

  Future<void> setNotifications(bool value) async {
    _updateState((state) => state.copyWith(notifications: value));
    await prefs.setBool('notifications', value);
  }

  Future<void> setFirebase(bool value) async {
    _updateState((state) => state.copyWith(firebase: value));
    await prefs.setBool('firebase', value);
  }

  Future<void> setWorkManager(bool value) async {
    _updateState((state) => state.copyWith(workManager: value));

    await prefs.setBool('workManager', value);

    if (value) {
      await ref.read(backgroundTaskManagerProvider).register();
    } else {
      await ref.read(backgroundTaskManagerProvider).cancel();
    }
  }

  Future<void> setBackgroundSchedule(BackgroundCheckSchedule value) async {
    _updateState((state) => state.copyWith(backgroundSchedule: value));

    await prefs.setString('backgroundSchedule', jsonEncode(value.toJson()));

    await ref.read(backgroundTaskManagerProvider).register();
  }

  Future<void> setTheme(AppThemes value) async {
    _updateState((state) => state.copyWith(theme: value));
    await prefs.setInt('theme', value.index);
  }

  Future<void> setDarkTheme(DarkTheme value) async {
    _updateState((state) => state.copyWith(darkTheme: value));
    await prefs.setInt('darkTheme', value.index);
  }

  Future<void> setThemeColor(Color? value) async {
    _updateState((state) => state.copyWith(themeColor: value));

    if (value == null) {
      await prefs.remove('themeColor');
    } else {
      await prefs.setInt('themeColor', value.toARGB32());
    }
  }

  void _updateState(SettingsState Function(SettingsState state) update) {
    state = AsyncData(update(state.requireValue));
  }

  Future<void> clear() async {
    await prefs.clear();
    state = AsyncData(SettingsState());
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
