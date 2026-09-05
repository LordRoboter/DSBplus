import 'package:material_ui/material_ui.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/features/timetables/model/timetable.dart';
import 'package:planner/l10n/app_localizations.dart';
import 'package:planner/l10n/l10extension.dart';

String ordinal(LessonRange? value, Locale locale) {
  if (value == null || value.lessons.isEmpty) return "";

  final sorted = value.lessons.toList()..sort();
  final ordinals = <String>[];
  var start = sorted.first;
  var end = sorted.first;

  for (int i = 1; i < sorted.length; i++) {
    if (sorted[i] == end + 1) {
      end = sorted[i];
    } else {
      ordinals.add(_formatRange(start, end, locale));
      start = sorted[i];
      end = sorted[i];
    }
  }

  ordinals.add(_formatRange(start, end, locale));
  return ordinals.join(", ");
}

String _formatRange(int start, int end, Locale locale) {
  if (start == end) {
    return _ordinalNumber(start, locale);
  } else {
    return '${_ordinalNumber(start, locale)}-${_ordinalNumber(end, locale)}';
  }
}

String _ordinalNumber(int number, Locale locale) {
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

String localizedWeekday(BuildContext context, Weekday? day) {
  return switch (day) {
    Weekday.monday => context.l10n.monday,
    Weekday.tuesday => context.l10n.tuesday,
    Weekday.wednesday => context.l10n.wednesday,
    Weekday.thursday => context.l10n.thursday,
    Weekday.friday => context.l10n.friday,
    Weekday.saturday => context.l10n.saturday,
    Weekday.sunday => context.l10n.sunday,
    _ => "",
  };
}

String localizedStatus(
  BuildContext context,
  TimetableStatusType? status, {
  bool original = false,
}) {
  return switch (status) {
    TimetableStatusType.substitution =>
      original ? "Vertretung" : context.l10n.substitution,

    TimetableStatusType.cancelled =>
      original ? "Eigenverantwortliches Arbeiten" : context.l10n.cancelled,

    TimetableStatusType.classChanged =>
      original ? "Unterricht geändert" : context.l10n.classChanged,

    TimetableStatusType.specialAssignment =>
      original ? "Sondereins." : context.l10n.specialAssignment,

    TimetableStatusType.roomSubstitution =>
      original ? "Raum-Vtr." : context.l10n.roomSubstitution,

    TimetableStatusType.event => original ? "Veranst." : context.l10n.event,

    TimetableStatusType.despiteAbsence =>
      original ? "TrotzAbsenz" : context.l10n.despiteAbsence,

    TimetableStatusType.substituteLesson =>
      original ? "Statt-Vertretung" : context.l10n.substituteLesson,

    TimetableStatusType.supervision =>
      original ? "Betreuung" : context.l10n.supervision,

    null => "",
  };
}

String localizedSubject(AppLocalizations l10n, String? subject) {
  if (subject == null || subject.isEmpty) return "";

  return switch (subject.toLowerCase()) {
    "d" => l10n.subjectGerman,
    "ds" => l10n.subjectDrama,
    "f" => l10n.subjectFrench,
    "spa" => l10n.subjectSpanish,
    "lat" || "l" => l10n.subjectLatin,
    "ph" => l10n.subjectPhysics,
    "ch" => l10n.subjectChemistry,
    "bio" => l10n.subjectBiology,
    "powi" => l10n.subjectPoliticsEconomics,
    "m" => l10n.subjectMathematics,
    "mu" => l10n.subjectMusic,
    "ethi" => l10n.subjectEthics,
    "rka" => l10n.subjectCatholicReligion,
    "g" => l10n.subjectHistory,
    "rev" => l10n.subjectProtestantReligion,
    "spo" => l10n.subjectSports,
    "e" => l10n.subjectEnglish,
    "ku" => l10n.subjectArt,
    "tut" => l10n.subjectTutorCourse,
    "chin" => l10n.subjectChinese,
    "info" => l10n.subjectComputerScience,
    "geo" => l10n.subjectGeography,
    _ => subject,
  };
}

String localizedRelativeWeekday(int diff, BuildContext context) {
  return switch (diff) {
    -1 => context.l10n.yesterday,
    0 => context.l10n.today,
    1 => context.l10n.tomorrow,
    _ => "",
  };
}

String localizedHours(BuildContext context, int hours) {
  final locale = Localizations.localeOf(context);

  if (locale.languageCode == 'de') {
    return hours == 1 ? '1 Stunde' : '$hours Stunden';
  }

  return hours == 1 ? '1 hour' : '$hours hours';
}

String localizedMinutes(BuildContext context, int minutes) {
  final locale = Localizations.localeOf(context);

  if (locale.languageCode == 'de') {
    return minutes == 1 ? '1 Minute' : '$minutes Minuten';
  }

  return minutes == 1 ? '1 minute' : '$minutes minutes';
}
