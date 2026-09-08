import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:planner/certificates.dart';
import 'package:planner/core/database/database.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/notifications/background_tasks.dart';
import 'package:planner/features/notifications/model/interval.dart';
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

  await runTimetableBackgroundCheck();
}

//TODO: Default Locale
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return runTimetableBackgroundCheck();
  });
}

Future<bool> runTimetableBackgroundCheck() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    HttpOverrides.global = MyHttpOverrides();

    await NotificationService.init();

    final settings = BackgroundSettingsRepository();
    await settings.init();

    final db = AppDatabase();

    final secureStorage = FlutterSecureStorage();
    final auth = AuthRepository(storage: secureStorage);

    final localeName = Platform.localeName;
    print(localeName);
    final locale = localeName.split("_")[0];
    final localeCode = locale != ""
        ? locale
        : settings.locale != null
        ? settings.locale.toString()
        : 'en';
    await initializeDateFormatting(localeCode);

    try {
      await performTimetableCheck(
        TimetableRepository(db, auth),
        settings,
        localeCode,
      );
    } finally {
      await db.close();
    }

    await scheduleNextBackgroundCheck(settings.backgroundSchedule);

    return true;
  } catch (e, stack) {
    debugPrint('WorkManager error: $e');
    debugPrint('$stack');

    return false;
  }
}

const backgroundTaskName = 'timetable-check';

Future<void> scheduleNextBackgroundCheck(
  BackgroundCheckSchedule schedule,
) async {
  final now = DateTime.now();

  final next = nextBackgroundCheckTime(now, schedule);

  if (next == null) {
    await Workmanager().cancelByUniqueName(backgroundTaskName);
    return;
  }

  final delay = next.difference(now);

  await Workmanager().registerOneOffTask(
    backgroundTaskName,
    backgroundTaskName,
    initialDelay: delay.isNegative ? Duration.zero : delay,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

Future<void> performTimetableCheck(
  TimetableRepository repository,
  BackgroundSettingsRepository settings,
  String localeCode,
) async {
  debugPrint("Executed");
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
    final formattedDate = DateFormat.yMd(localeCode).format(date);

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

    final enhancedAdded = enhanceClassedEntries(
      l10n,
      diff.added,
      settings.clean,
      settings.simplify,
      disposeTut: settings.disposeTut,
      cleanClassNames: settings.cleanClassNames,
      remapTypes: settings.remapTypes,
      cleanupCourses: settings.cleanupCourses,
      disposeCourseNumbers: settings.disposeCourseNumbers,
      mapCourses: settings.mapCourses,
    );

    final enhancedRemoved = enhanceClassedEntries(
      l10n,
      diff.removed,
      settings.clean,
      settings.simplify,
      disposeTut: settings.disposeTut,
      cleanClassNames: settings.cleanClassNames,
      remapTypes: settings.remapTypes,
      cleanupCourses: settings.cleanupCourses,
      disposeCourseNumbers: settings.disposeCourseNumbers,
      mapCourses: settings.mapCourses,
    );

    final addedEntries = enhancedAdded
        .map(
          (entry) => l10n.entryInfo(
            ordinal(entry.entry.lesson, Locale(localeCode)),
            localizedStatus(l10n, entry.entry.type),
            localizedSubject(l10n, entry.entry.subject),
            entry.entry.teacher ?? "",
          ),
        )
        .join("\n");

    final removedEntries = enhancedRemoved
        .map(
          (entry) => l10n.entryInfoDeleted(
            ordinal(entry.entry.lesson, Locale(localeCode)),
            localizedStatus(l10n, entry.entry.type),
            localizedSubject(l10n, entry.entry.subject),
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
