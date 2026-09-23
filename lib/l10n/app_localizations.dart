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

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Planner'**
  String get welcome;

  /// No description provided for @welcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your DSB credentials to get started and access your substitution plans.'**
  String get welcomeDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

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

  /// No description provided for @dateP.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateP;

  /// No description provided for @updatedP.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedP;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @planDetails.
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get planDetails;

  /// No description provided for @fetchedAt.
  ///
  /// In en, this message translates to:
  /// **'First Fetch'**
  String get fetchedAt;

  /// No description provided for @lastFetchedAt.
  ///
  /// In en, this message translates to:
  /// **'Most recent Fetch'**
  String get lastFetchedAt;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @credentialsExp.
  ///
  /// In en, this message translates to:
  /// **'Credentials for using DSB'**
  String get credentialsExp;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @credentialsSaved.
  ///
  /// In en, this message translates to:
  /// **'Credentials saved'**
  String get credentialsSaved;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 187801'**
  String get usernameHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageExp.
  ///
  /// In en, this message translates to:
  /// **'The display language of the app'**
  String get languageExp;

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

  /// No description provided for @collapseClassNames.
  ///
  /// In en, this message translates to:
  /// **'Collapse class names'**
  String get collapseClassNames;

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

  /// No description provided for @workManager.
  ///
  /// In en, this message translates to:
  /// **'Periodical Checks'**
  String get workManager;

  /// No description provided for @workManagerDesc.
  ///
  /// In en, this message translates to:
  /// **'Local periodical checks to detect new plans'**
  String get workManagerDesc;

  /// No description provided for @backgroundCheckSchedule.
  ///
  /// In en, this message translates to:
  /// **'Background check schedule'**
  String get backgroundCheckSchedule;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get days;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

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

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

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

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @dynamicc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get dynamicc;

  /// No description provided for @defaultt.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultt;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @substitution.
  ///
  /// In en, this message translates to:
  /// **'Substitution'**
  String get substitution;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @classChanged.
  ///
  /// In en, this message translates to:
  /// **'Class changed'**
  String get classChanged;

  /// No description provided for @specialAssignment.
  ///
  /// In en, this message translates to:
  /// **'Special assignment'**
  String get specialAssignment;

  /// No description provided for @roomSubstitution.
  ///
  /// In en, this message translates to:
  /// **'Room substitution'**
  String get roomSubstitution;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @despiteAbsence.
  ///
  /// In en, this message translates to:
  /// **'Despite absence'**
  String get despiteAbsence;

  /// No description provided for @substituteLesson.
  ///
  /// In en, this message translates to:
  /// **'Substitute lesson'**
  String get substituteLesson;

  /// No description provided for @supervision.
  ///
  /// In en, this message translates to:
  /// **'Supervision'**
  String get supervision;

  /// No description provided for @rescheduling.
  ///
  /// In en, this message translates to:
  /// **'Rescheduling'**
  String get rescheduling;

  /// No description provided for @subjectGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get subjectGerman;

  /// No description provided for @subjectDrama.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get subjectDrama;

  /// No description provided for @subjectFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get subjectFrench;

  /// No description provided for @subjectSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get subjectSpanish;

  /// No description provided for @subjectLatin.
  ///
  /// In en, this message translates to:
  /// **'Latin'**
  String get subjectLatin;

  /// No description provided for @subjectPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get subjectPhysics;

  /// No description provided for @subjectChemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get subjectChemistry;

  /// No description provided for @subjectBiology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get subjectBiology;

  /// No description provided for @subjectPoliticsEconomics.
  ///
  /// In en, this message translates to:
  /// **'Politics & Economics'**
  String get subjectPoliticsEconomics;

  /// No description provided for @subjectMathematics.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get subjectMathematics;

  /// No description provided for @subjectMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get subjectMusic;

  /// No description provided for @subjectEthics.
  ///
  /// In en, this message translates to:
  /// **'Ethics'**
  String get subjectEthics;

  /// No description provided for @subjectCatholicReligion.
  ///
  /// In en, this message translates to:
  /// **'Catholic Religion'**
  String get subjectCatholicReligion;

  /// No description provided for @subjectHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get subjectHistory;

  /// No description provided for @subjectProtestantReligion.
  ///
  /// In en, this message translates to:
  /// **'Protestant Religion'**
  String get subjectProtestantReligion;

  /// No description provided for @subjectSports.
  ///
  /// In en, this message translates to:
  /// **'PE'**
  String get subjectSports;

  /// No description provided for @subjectEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subjectEnglish;

  /// No description provided for @subjectArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get subjectArt;

  /// No description provided for @subjectTutorCourse.
  ///
  /// In en, this message translates to:
  /// **'Tutor Course'**
  String get subjectTutorCourse;

  /// No description provided for @subjectChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get subjectChinese;

  /// No description provided for @subjectComputerScience.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get subjectComputerScience;

  /// No description provided for @subjectGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get subjectGeography;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @noResourcesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Resources available'**
  String get noResourcesAvailable;

  /// No description provided for @couldNotLoadResources.
  ///
  /// In en, this message translates to:
  /// **'Could not load Resources'**
  String get couldNotLoadResources;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @notificationsWereNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications were not enabled'**
  String get notificationsWereNotEnabled;

  /// No description provided for @couldNotNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not enable notifications:'**
  String get couldNotNotifications;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @customizePlanner.
  ///
  /// In en, this message translates to:
  /// **'Customize the App to work the way you want'**
  String get customizePlanner;

  /// No description provided for @filtersDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which classes and changes you want to see'**
  String get filtersDesc;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when relevant changes are available'**
  String get notificationsDesc;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are NOT enabled'**
  String get notificationsNotEnabled;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @appearanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize what the app looks like'**
  String get appearanceDesc;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @youCanChangeSettings.
  ///
  /// In en, this message translates to:
  /// **'You can still change these settings later'**
  String get youCanChangeSettings;

  /// No description provided for @checkingPermission.
  ///
  /// In en, this message translates to:
  /// **'Checking notification permission...'**
  String get checkingPermission;

  /// No description provided for @notificationsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are allowed'**
  String get notificationsAllowed;

  /// No description provided for @notificationsNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are NOT allowed'**
  String get notificationsNotAllowed;

  /// No description provided for @notificationsCanBeSent.
  ///
  /// In en, this message translates to:
  /// **'The app can send you notifications'**
  String get notificationsCanBeSent;

  /// No description provided for @allowNotificationsExp.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to be informed when your timetable changes'**
  String get allowNotificationsExp;

  /// No description provided for @requesting.
  ///
  /// In en, this message translates to:
  /// **'Requesting...'**
  String get requesting;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @notificationSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'You can fine-tune notifications in settings'**
  String get notificationSettingsHint;

  /// No description provided for @batteryOptimizationHint.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization might restrict background checks'**
  String get batteryOptimizationHint;

  /// No description provided for @batterySettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get batterySettings;

  /// No description provided for @batteryOptimizationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization is disabled for this app'**
  String get batteryOptimizationDisabled;
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
