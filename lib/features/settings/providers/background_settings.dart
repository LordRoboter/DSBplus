import 'dart:convert';
import 'dart:ui';

import 'package:planner/features/notifications/model/interval.dart';
import 'package:planner/features/timetables/model/filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSettingsRepository {
  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Locale? get locale {
    final value = prefs.getString('locale');

    if (value == null) {
      return null;
    }

    return Locale.fromSubtags(languageCode: value.split('-').first);
  }

  bool get notifications => prefs.getBool('notifications') ?? true;
  bool get firebase => prefs.getBool('firebase') ?? true;
  BackgroundCheckSchedule get backgroundSchedule {
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

  TimetableFilter get classFilter {
    final value = prefs.getString('classFilter');

    if (value == null) {
      return const TimetableFilter();
    }

    return TimetableFilter.fromJson(jsonDecode(value));
  }

  bool get clean => prefs.getBool('clean') ?? true;
  bool get simplify => prefs.getBool('simplify') ?? true;
  bool get disposeTut => prefs.getBool('disposeTut') ?? true;
  bool get cleanClassNames => prefs.getBool('cleanClassNames') ?? true;
  bool get remapTypes => prefs.getBool('remapTypes') ?? true;
  bool get cleanupCourses => prefs.getBool('cleanupCourses') ?? true;
  bool get disposeCourseNumbers =>
      prefs.getBool('disposeCourseNumbers') ?? true;
  bool get mapCourses => prefs.getBool('mapCourses') ?? true;
  bool get collapse => prefs.getBool('collapse') ?? true;
}
