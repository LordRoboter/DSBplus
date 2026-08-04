class DayDate {
  final String? day;
  final DateTime? date;

  DayDate(this.day, this.date);

  factory DayDate.fromJson(Map<String, dynamic> json) {
    return DayDate(json['day'], DateTime.parse(json['date']));
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'date': date?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) {
    return other is DayDate && other.day == day && other.date == date;
  }

  @override
  int get hashCode => Object.hash(day, date);
}
