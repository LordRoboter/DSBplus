// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get plan => 'Plan';

  @override
  String get substPlan => 'Vertretungsplan';

  @override
  String get newEntries => 'Neue Einträge!';

  @override
  String entryInfo(
    Object lessonOrdinal,
    Object subject,
    Object teacher,
    Object type,
  ) {
    return '$lessonOrdinal Stunde: $type $subject $teacher';
  }

  @override
  String entryInfoDeleted(
    Object lessonOrdinal,
    Object subject,
    Object teacher,
    Object type,
  ) {
    return '$lessonOrdinal Stunde: $type $subject $teacher - Entfernt';
  }

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get yesterday => 'Gestern';

  @override
  String get newEntriess => 'Neue Einträge';

  @override
  String get timetableChanged => 'Vertretungsplanänderung';

  @override
  String get deletedEntries => 'Gelöschte Einträge';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get unknown => 'Unknown';
}
