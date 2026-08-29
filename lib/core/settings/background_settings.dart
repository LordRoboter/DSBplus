import 'dart:convert';

import 'package:planner/core/model/filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSettingsRepository {
  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool get notifications => prefs.getBool('notifications') ?? false;
  bool get firebase => prefs.getBool('firebase') ?? false;

  TimetableFilter get classFilter {
    final value = prefs.getString('classFilter');

    if (value == null) {
      return const TimetableFilter();
    }

    return TimetableFilter.fromJson(jsonDecode(value));
  }
}
