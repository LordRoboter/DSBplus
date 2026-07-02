import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dsb_api.dart';
import 'data_repository.dart';

class PlanRepository extends ChangeNotifier {
  final DataRepository data;

  PlanRepository(this.data);

  List<Map<String, dynamic>> entries = [];

  bool loading = true;
  String? error;

  String get lastUpdated => data.lastUpdated;

  List<String> get availableDays =>
      entries.map((e) => e["day"] as String).toSet().toList();

  Future<void> init() async {
    entries = data.cachedEntries;
    await loadData();
  }

  Future<void> loadData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final api = DSBApi(
        "REMOVED",
        "REMOVED",
        tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
      );

      entries = await api.fetchEntries();

      await data.validateSelectedDay(availableDays);

      await data.saveEntries(entries);

      await data.saveUpdated(
        DateFormat('dd.MM. HH:mm', 'de_DE').format(DateTime.now()),
      );

      loading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }
}
