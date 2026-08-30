import 'dart:convert';

import 'package:planner/features/timetables/model/filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSettingsRepository {
  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool get notifications => prefs.getBool('notifications') ?? true;
  bool get firebase => prefs.getBool('firebase') ?? true;

  TimetableFilter get classFilter {
    final value = prefs.getString('classFilter');

    if (value == null) {
      return const TimetableFilter();
    }

    return TimetableFilter.fromJson(jsonDecode(value));
  }
}
