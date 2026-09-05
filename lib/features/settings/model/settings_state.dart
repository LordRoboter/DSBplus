import 'dart:ui';

//import 'package:planner/core/model/daydate.dart';
import 'package:planner/features/timetables/model/filter.dart';
import 'package:planner/theme.dart';

class SettingsState {
  final bool startupComplete;
  final Locale? locale;
  //final DayDate? selectedDayDate;

  final bool clean;
  final bool simplify;
  final bool disposeTut;
  final bool cleanClassNames;
  final bool remapTypes;
  final bool cleanupCourses;
  final bool disposeCourseNumbers;
  final bool mapCourses;
  final bool collapse;

  final bool notifications;
  final bool firebase;
  final bool workManager;

  final List<TimetableFilter> filters;
  final TimetableFilter classFilter;

  final AppThemes theme;
  final DarkTheme darkTheme;
  final ThemeColor themeColor;

  const SettingsState({
    this.startupComplete = false,
    this.locale,
    //this.selectedDayDate,
    this.clean = true,
    this.simplify = true,
    this.disposeTut = true,
    this.cleanClassNames = true,
    this.remapTypes = true,
    this.cleanupCourses = true,
    this.disposeCourseNumbers = true,
    this.mapCourses = true,
    this.collapse = false,
    this.notifications = true,
    this.firebase = true,
    this.workManager = true,
    this.filters = const [],
    this.classFilter = const TimetableFilter(),
    this.theme = AppThemes.system,
    this.darkTheme = DarkTheme.dark,
    this.themeColor = const StandardColor(),
  });

  static const _unset = Object();

  SettingsState copyWith({
    bool? startupComplete,
    Object? locale = _unset,
    //DayDate? selectedDayDate,
    bool? clean,
    bool? simplify,
    bool? disposeTut,
    bool? cleanClassNames,
    bool? remapTypes,
    bool? cleanupCourses,
    bool? disposeCourseNumbers,
    bool? mapCourses,
    bool? collapse,
    bool? notifications,
    bool? firebase,
    bool? workManager,
    List<TimetableFilter>? filters,
    TimetableFilter? classFilter,
    AppThemes? theme,
    DarkTheme? darkTheme,
    ThemeColor? themeColor,
  }) {
    return SettingsState(
      startupComplete: startupComplete ?? this.startupComplete,
      locale: locale == _unset ? this.locale : locale as Locale?,
      //selectedDayDate: selectedDayDate ?? this.selectedDayDate,
      clean: clean ?? this.clean,
      simplify: simplify ?? this.simplify,
      disposeTut: disposeTut ?? this.disposeTut,
      cleanClassNames: cleanClassNames ?? this.cleanClassNames,
      remapTypes: remapTypes ?? this.remapTypes,
      cleanupCourses: cleanupCourses ?? this.cleanupCourses,
      disposeCourseNumbers: disposeCourseNumbers ?? this.disposeCourseNumbers,
      mapCourses: mapCourses ?? this.mapCourses,
      collapse: collapse ?? this.collapse,
      notifications: notifications ?? this.notifications,
      firebase: firebase ?? this.firebase,
      workManager: workManager ?? this.workManager,
      filters: filters ?? this.filters,
      classFilter: classFilter ?? this.classFilter,
      theme: theme ?? this.theme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
