import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:planner/certificates.dart';
import 'package:planner/core/model/daydate.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/core/util/sorter.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/firebase_options.dart';
import 'package:planner/l10n/app_localizations.dart';
import 'package:planner/services/data_repository.dart';
import 'package:planner/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.data["type"] != "timetable_updated") return;

  final settings = await SharedPreferences.getInstance();

  final backgroundNotifications = settings.getBool("notifications") ?? true;
  final firebaseNotifications = settings.getBool("firebase") ?? true;

  if (!backgroundNotifications || !firebaseNotifications) {
    return;
  }

  final data = DataRepository();
  await data.init();

  HttpOverrides.global = MyHttpOverrides();
  await NotificationService.init();

  await performTimetableCheck(data);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      HttpOverrides.global = MyHttpOverrides();

      await NotificationService.init();

      final data = DataRepository();
      await data.init();

      await performTimetableCheck(data);

      return true;
    } catch (e, stack) {
      debugPrint('WorkManager error: $e');
      debugPrint('$stack');

      return false;
    }
  });
}

@pragma('vm:entry-point')
Future<void> performTimetableCheck(DataRepository data) async {
  final oldData = await data.sync();
  final newData = data.cachedEntries;

  final groupedOld = {
    for (final timetable in oldData)
      DayDate(timetable.day, timetable.date): timetable,
  };

  final groupedNew = {
    for (final timetable in newData)
      DayDate(timetable.day, timetable.date): timetable,
  };

  final localeCode = PlatformDispatcher.instance.locale.languageCode;
  final l10n = await AppLocalizations.delegate.load(Locale(localeCode));
  await initializeDateFormatting(localeCode);

  for (final dayDate in data.availableDayDates) {
    final diff = diffByClass(
      groupedOld[dayDate],
      groupedNew[dayDate],
      data.classFilter.classes,
    );

    if (!diff.hasChanges) continue;

    final date = dayDate.date!;
    final formattedDate = DateFormat.yMd(Locale(localeCode)).format(date);

    final relativeDay = getRelativeDay(date);

    final dayName = switch (relativeDay) {
      0 => l10n.today,
      1 => l10n.tomorrow,
      -1 => l10n.yesterday,
      _ => "${dayDate.day} ($formattedDate)",
    };

    final title = diff.added.isNotEmpty && diff.removed.isNotEmpty
        ? "$dayName: ${l10n.timetableChanged}"
        : diff.added.isNotEmpty
        ? "$dayName: ${l10n.newEntries}"
        : "$dayName: ${l10n.deletedEntries}";

    final addedEntries = diff.added
        .map(
          (entry) => l10n.entryInfo(
            ordinal(entry.entry.lesson, Locale(localeCode)),
            entry.entry.type ?? "",
            entry.entry.subject ?? "",
            entry.entry.teacher ?? "",
          ),
        )
        .join("\n");

    final removedEntries = diff.removed
        .map(
          (entry) => l10n.entryInfoDeleted(
            ordinal(entry.entry.lesson, Locale(localeCode)),
            entry.entry.type ?? "",
            entry.entry.subject ?? "",
            entry.entry.teacher ?? "",
          ),
        )
        .join("\n");

    final details = [
      if (diff.added.isNotEmpty) addedEntries,
      if (diff.removed.isNotEmpty) removedEntries,
    ].join("\n");

    await NotificationService.makeUpdateNotification(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 +
          data.availableDayDates.indexOf(dayDate),
      title,
      details,
    );
  }
}
