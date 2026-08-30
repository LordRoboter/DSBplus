import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:planner/certificates.dart';
import 'package:planner/core/database/database.dart';
import 'package:planner/features/timetables/model/daydate.dart';
import 'package:planner/features/settings/providers/background_settings.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/core/util/sorter.dart';
import 'package:planner/core/util/timetable.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/firebase_options.dart';
import 'package:planner/l10n/app_localizations.dart';
import 'package:planner/features/timetables/data/timetable_repository.dart';
import 'package:planner/features/notifications/notification_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.data["type"] != "timetable_updated") return;

  final settings = BackgroundSettingsRepository();
  await settings.init();

  final backgroundNotifications = settings.notifications;
  final firebaseNotifications = settings.firebase;

  if (!backgroundNotifications || !firebaseNotifications) {
    return;
  }

  HttpOverrides.global = MyHttpOverrides();
  await NotificationService.init();

  final db = AppDatabase();
  try {
    await performTimetableCheck(TimetableRepository(db), settings);
  } finally {
    await db.close();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      HttpOverrides.global = MyHttpOverrides();

      await NotificationService.init();

      final settings = BackgroundSettingsRepository();
      await settings.init();
      final db = AppDatabase();

      try {
        await performTimetableCheck(TimetableRepository(db), settings);
      } finally {
        await db.close();
      }

      return true;
    } catch (e, stack) {
      debugPrint('WorkManager error: $e');
      debugPrint('$stack');

      return false;
    }
  });
}

@pragma('vm:entry-point')
Future<void> performTimetableCheck(
  TimetableRepository repository,
  BackgroundSettingsRepository settings,
) async {
  final oldData = await repository.loadAll();
  final newData = await repository.sync(oldData);

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

  for (final dayDate in availableDayDates(newData)) {
    final diff = diffByClass(
      groupedOld[dayDate],
      groupedNew[dayDate],
      settings.classFilter.classes,
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
          availableDayDates(newData).indexOf(dayDate),
      title,
      details,
    );
  }
}
