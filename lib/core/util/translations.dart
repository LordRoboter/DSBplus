import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:planner/core/models/timetable.dart';
import 'package:planner/l10n/l10extension.dart';

String ordinal(String? value, Locale locale) {
  if (value == null || value.isEmpty) return "";

  if (value.contains("-")) {
    return value.split("-").map((part) => ordinal(part, locale)).join("-");
  }

  final number = int.tryParse(value);
  if (number == null) return value;

  switch (locale.languageCode) {
    case 'de':
      return '$number.';

    case 'en':
      final mod100 = number % 100;
      if (mod100 >= 11 && mod100 <= 13) {
        return '${number}th';
      }

      return switch (number % 10) {
        1 => '${number}st',
        2 => '${number}nd',
        3 => '${number}rd',
        _ => '${number}th',
      };

    default:
      return number.toString();
  }
}

String localizedWeekday(BuildContext context, Weekday day) {
  return switch (day) {
    Weekday.monday => context.l10n.monday,
    Weekday.tuesday => context.l10n.tuesday,
    Weekday.wednesday => context.l10n.wednesday,
    Weekday.thursday => context.l10n.thursday,
    Weekday.friday => context.l10n.friday,
    Weekday.saturday => context.l10n.saturday,
    Weekday.sunday => context.l10n.sunday,
  };
}
