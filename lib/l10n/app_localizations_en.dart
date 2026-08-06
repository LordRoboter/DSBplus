// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get plan => 'Plan';

  @override
  String get substPlan => 'Substitution Plan';

  @override
  String get newEntries => 'New Entries!';

  @override
  String entryInfo(
    Object lessonOrdinal,
    Object subject,
    Object teacher,
    Object type,
  ) {
    return '$lessonOrdinal lesson: $type $subject $teacher';
  }

  @override
  String entryInfoDeleted(
    Object lessonOrdinal,
    Object subject,
    Object teacher,
    Object type,
  ) {
    return '$lessonOrdinal lesson: $type $subject $teacher - Deleted';
  }

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get newEntriess => 'New Entries';

  @override
  String get timetableChanged => 'Timetable changed';

  @override
  String get deletedEntries => 'Deleted Entries';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get unknown => 'Unknown';
}
