import 'timetable.dart';

class DayDate {
  final Weekday? day;
  final DateTime? date;

  DayDate(this.day, this.date);

  factory DayDate.fromJson(Map<String, dynamic> json) {
    return DayDate(
      json['day'] != null ? Weekday.values[json['day']] : null,
      json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day?.index,
    'date': date?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) {
    return other is DayDate && other.day == day && other.date == date;
  }

  @override
  int get hashCode => Object.hash(day, date);
}
