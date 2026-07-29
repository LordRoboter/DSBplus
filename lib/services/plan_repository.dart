import 'package:flutter/material.dart';
import 'package:planner/util/date.dart';

import 'data_repository.dart';

class PlanRepository extends ChangeNotifier {
  final DataRepository data;

  PlanRepository(this.data);

  List<Map<String, dynamic>> entries = [];

  bool loading = true;
  String? error;

  String get lastUpdated => data.lastUpdated;

  List<String> get availableDayDates =>
      entries.map((e) => formatDayDate(e)).toSet().toList();

  Future<void> init() async {
    entries = data.cachedEntries;
    await loadData();
  }

  Future<void> loadData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await data.sync();

      entries = data.cachedEntries;

      loading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }
}
