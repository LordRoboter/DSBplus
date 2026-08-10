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
  String get noRelevantEntries => 'No relevant Entries •︵•';

  @override
  String get noEntries => 'No Entries ( – ⤙ – )';

  @override
  String get newEntries => 'New Entries!';

  @override
  String get outdatedEntry => 'This entry is probably outdated';

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
  String get lsn => 'lesson';

  @override
  String get lesson => 'lesson';

  @override
  String get classs => 'Class';

  @override
  String get subject => 'Subject';

  @override
  String get addFilter => 'Add Filter';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

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

  @override
  String get search => 'Search...';

  @override
  String get date => 'Date: ';

  @override
  String get updated => 'Updated: ';

  @override
  String get dateP => 'Date';

  @override
  String get updatedP => 'Updated';

  @override
  String get day => 'Day';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get planDetails => 'Plan Details';

  @override
  String get fetchedAt => 'First Fetch';

  @override
  String get lastFetchedAt => 'Most recent Fetch';

  @override
  String get settings => 'Settings';

  @override
  String get notificationsExp => 'Notifications for new entries';

  @override
  String get enhanceEntries => 'Enhance Entries';

  @override
  String get filters => 'Filters';

  @override
  String get filtersExp => 'Filter by classes and lessons';

  @override
  String get language => 'Language';

  @override
  String get languageExp => 'The display language of the app';

  @override
  String get filter => 'Filter';

  @override
  String get classFilter => 'Class Filter';

  @override
  String get classFilterHint => 'e.g. 10a';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get help => 'Help';

  @override
  String get cleanup => 'Cleanup';

  @override
  String get simplifyEntries => 'Simplify Entries';

  @override
  String get simplifyEntriesSub => 'Merge duplicate entries';

  @override
  String get cleanupEntries => 'Cleanup Entries';

  @override
  String get cleanupEntriesSub => 'Make entries easier to read';

  @override
  String get cleanupOptions => 'Cleanup options';

  @override
  String get simplifyClassNames => 'Simplify class names';

  @override
  String get simplifyLessonStatus => 'Simplify lesson status';

  @override
  String get simplifyCourses => 'Simplify courses';

  @override
  String get mergeTutorCourses => 'Merge tutor courses';

  @override
  String get renameSubjects => 'Rename subjects';

  @override
  String get removeCourseNumbers => 'Remove course numbers';

  @override
  String get notifications => 'Notifications';

  @override
  String get appearance => 'Appearance';

  @override
  String get appTheme => 'App theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get standard => 'Default';

  @override
  String get amoled => 'AMOLED';

  @override
  String get systemDefault => 'System Default';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get substitution => 'Substitution';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get classChanged => 'Class changed';

  @override
  String get specialAssignment => 'Special assignment';

  @override
  String get roomSubstitution => 'Room substitution';

  @override
  String get event => 'Event';

  @override
  String get despiteAbsence => 'Despite absence';

  @override
  String get substituteLesson => 'Substitute lesson';

  @override
  String get supervision => 'Supervision';

  @override
  String get subjectGerman => 'German';

  @override
  String get subjectDrama => 'Drama';

  @override
  String get subjectFrench => 'French';

  @override
  String get subjectSpanish => 'Spanish';

  @override
  String get subjectLatin => 'Latin';

  @override
  String get subjectPhysics => 'Physics';

  @override
  String get subjectChemistry => 'Chemistry';

  @override
  String get subjectBiology => 'Biology';

  @override
  String get subjectPoliticsEconomics => 'Politics & Economics';

  @override
  String get subjectMathematics => 'Mathematics';

  @override
  String get subjectMusic => 'Music';

  @override
  String get subjectEthics => 'Ethics';

  @override
  String get subjectCatholicReligion => 'Catholic Religion';

  @override
  String get subjectHistory => 'History';

  @override
  String get subjectProtestantReligion => 'Protestant Religion';

  @override
  String get subjectSports => 'PE';

  @override
  String get subjectEnglish => 'English';

  @override
  String get subjectArt => 'Art';

  @override
  String get subjectTutorCourse => 'Tutor Course';

  @override
  String get subjectChinese => 'Chinese';

  @override
  String get subjectComputerScience => 'Computer Science';

  @override
  String get subjectGeography => 'Geography';
}
