import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/notifications/model/interval.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:workmanager/workmanager.dart';

final backgroundTaskManagerProvider = Provider<BackgroundTaskManager>((ref) {
  return BackgroundTaskManager(ref: ref);
});

class BackgroundTaskManager {
  BackgroundTaskManager({required this.ref});

  final Ref ref;

  static const taskName = 'timetable-check';

  Future<void> register() async {
    final settings = await ref.read(settingsProvider.future);

    if (!settings.workManager) {
      await cancel();
      return;
    }

    await _scheduleNext(settings.backgroundSchedule);
  }

  Future<void> _scheduleNext(BackgroundCheckSchedule schedule) async {
    final now = DateTime.now();

    final next = nextBackgroundCheckTime(now, schedule);

    if (next == null) {
      await cancel();
      return;
    }

    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: next.difference(now),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> cancel() {
    return Workmanager().cancelByUniqueName(taskName);
  }
}

DateTime? nextBackgroundCheckTime(
  DateTime now,
  BackgroundCheckSchedule schedule,
) {
  for (var dayOffset = 0; dayOffset < 8; dayOffset++) {
    final date = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: dayOffset));

    //TODO: This might be unstable in the future
    if (!schedule.days.contains(Weekday.values[date.weekday - 1])) {
      continue;
    }

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      schedule.startTime ~/ 60,
      schedule.startTime % 60,
    );

    final end = DateTime(
      date.year,
      date.month,
      date.day,
      schedule.endTime ~/ 60,
      schedule.endTime % 60,
    );

    if (dayOffset == 0 && now.isAfter(end)) {
      continue;
    }

    DateTime candidate;

    if (dayOffset == 0 && now.isBefore(start)) {
      candidate = start;
    } else if (dayOffset == 0) {
      final elapsed = now.difference(start);
      final intervals = elapsed.inMinutes ~/ schedule.interval.inMinutes;

      candidate = start.add(
        Duration(minutes: (intervals + 1) * schedule.interval.inMinutes),
      );
    } else {
      candidate = start;
    }

    if (candidate.isBefore(end) || candidate.isAtSameMomentAs(end)) {
      return candidate;
    }
  }

  return null;
}
