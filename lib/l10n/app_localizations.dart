import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @substPlan.
  ///
  /// In en, this message translates to:
  /// **'Substitution Plan'**
  String get substPlan;

  /// No description provided for @noRelevantEntries.
  ///
  /// In en, this message translates to:
  /// **'No relevant Entries •︵•'**
  String get noRelevantEntries;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No Entries ( – ⤙ – )'**
  String get noEntries;

  /// No description provided for @newEntries.
  ///
  /// In en, this message translates to:
  /// **'New Entries!'**
  String get newEntries;

  /// No description provided for @outdatedEntry.
  ///
  /// In en, this message translates to:
  /// **'This entry is probably outdated'**
  String get outdatedEntry;

  /// No description provided for @entryInfo.
  ///
  /// In en, this message translates to:
  /// **'{lessonOrdinal} lesson: {type} {subject} {teacher}'**
  String entryInfo(
    Object lessonOrdinal,
    Object subject,
    Object teacher,
    Object type,
  );

  /// No description provided for @entryInfoDeleted.
  ///
  /// In en, this message translates to:
  /// **'{lessonOrdinal} lesson: {type} {subject} {teacher} - Deleted'**
  String entryInfoDeleted(
    Object lessonOrdinal,
    Object subject,
    Object teacher,
    Object type,
  );

  /// No description provided for @lsn.
  ///
  /// In en, this message translates to:
  /// **'lesson'**
  String get lsn;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'lesson'**
  String get lesson;

  /// No description provided for @classs.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classs;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @addFilter.
  ///
  /// In en, this message translates to:
  /// **'Add Filter'**
  String get addFilter;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @newEntriess.
  ///
  /// In en, this message translates to:
  /// **'New Entries'**
  String get newEntriess;

  /// No description provided for @timetableChanged.
  ///
  /// In en, this message translates to:
  /// **'Timetable changed'**
  String get timetableChanged;

  /// No description provided for @deletedEntries.
  ///
  /// In en, this message translates to:
  /// **'Deleted Entries'**
  String get deletedEntries;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get date;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated: '**
  String get updated;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notificationsExp.
  ///
  /// In en, this message translates to:
  /// **'Notifications for new entries'**
  String get notificationsExp;

  /// No description provided for @enhanceEntries.
  ///
  /// In en, this message translates to:
  /// **'Enhance Entries'**
  String get enhanceEntries;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtersExp.
  ///
  /// In en, this message translates to:
  /// **'Filter by classes and lessons'**
  String get filtersExp;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @classFilter.
  ///
  /// In en, this message translates to:
  /// **'Class Filter'**
  String get classFilter;

  /// No description provided for @classFilterHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10a'**
  String get classFilterHint;

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @cleanup.
  ///
  /// In en, this message translates to:
  /// **'Cleanup'**
  String get cleanup;

  /// No description provided for @simplifyEntries.
  ///
  /// In en, this message translates to:
  /// **'Simplify Entries'**
  String get simplifyEntries;

  /// No description provided for @simplifyEntriesSub.
  ///
  /// In en, this message translates to:
  /// **'Merge duplicate entries'**
  String get simplifyEntriesSub;

  /// No description provided for @cleanupEntries.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Entries'**
  String get cleanupEntries;

  /// No description provided for @cleanupEntriesSub.
  ///
  /// In en, this message translates to:
  /// **'Make entries easier to read'**
  String get cleanupEntriesSub;

  /// No description provided for @cleanupOptions.
  ///
  /// In en, this message translates to:
  /// **'Cleanup options'**
  String get cleanupOptions;

  /// No description provided for @simplifyClassNames.
  ///
  /// In en, this message translates to:
  /// **'Simplify class names'**
  String get simplifyClassNames;

  /// No description provided for @simplifyLessonStatus.
  ///
  /// In en, this message translates to:
  /// **'Simplify lesson status'**
  String get simplifyLessonStatus;

  /// No description provided for @simplifyCourses.
  ///
  /// In en, this message translates to:
  /// **'Simplify courses'**
  String get simplifyCourses;

  /// No description provided for @mergeTutorCourses.
  ///
  /// In en, this message translates to:
  /// **'Merge tutor courses'**
  String get mergeTutorCourses;

  /// No description provided for @renameSubjects.
  ///
  /// In en, this message translates to:
  /// **'Rename subjects'**
  String get renameSubjects;

  /// No description provided for @removeCourseNumbers.
  ///
  /// In en, this message translates to:
  /// **'Remove course numbers'**
  String get removeCourseNumbers;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get appTheme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get standard;

  /// No description provided for @amoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get amoled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
