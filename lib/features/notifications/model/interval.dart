import 'package:planner/core/model/weekday.dart';

enum BackgroundCheckInterval {
  fifteenMinutes,
  thirtyMinutes,
  oneHour,
  threeHours,
  sixHours,
  twelveHours,
}

class BackgroundCheckSchedule {
  final Set<Weekday> days;
  final int startTime;
  final int endTime;
  final Duration interval;

  const BackgroundCheckSchedule({
    this.days = const {
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
    },
    this.startTime = 7 * 60,
    this.endTime = 18 * 60,
    this.interval = const Duration(minutes: 30),
  });

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((day) => day.name).toList(),
      'startTime': startTime,
      'endTime': endTime,
      'interval': interval.inMinutes,
    };
  }

  factory BackgroundCheckSchedule.fromJson(Map<String, dynamic> json) {
    return BackgroundCheckSchedule(
      days: (json['days'] as List<dynamic>? ?? [])
          .map((value) => Weekday.values.byName(value as String))
          .toSet(),
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int,
      interval: Duration(minutes: json['interval'] as int),
    );
  }

  BackgroundCheckSchedule copyWith({
    Set<Weekday>? days,
    int? startTime,
    int? endTime,
    Duration? interval,
  }) {
    return BackgroundCheckSchedule(
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      interval: interval ?? this.interval,
    );
  }
}
