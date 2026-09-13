// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcome => 'Wilkommen zu Planner';

  @override
  String get welcomeDesc =>
      'Gib deine DSB Benutzerdaten ein, um auf deine Vertretungspläne zugreifen zu können.';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get home => 'Home';

  @override
  String get plan => 'Vertretungsplan';

  @override
  String get substPlan => 'Vertretungsplan';

  @override
  String get noRelevantEntries => 'Keine relevanten Einträge •︵•';

  @override
  String get noEntries => 'Keine Einträge ( – ⤙ – )';

  @override
  String get newEntries => 'Neue Einträge!';

  @override
  String get outdatedEntry => 'Dieser Eintrag ist wahrscheinlich veraltet';

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
  String get lsn => 'Std';

  @override
  String get lesson => 'Stunde';

  @override
  String get classs => 'Klasse';

  @override
  String get subject => 'Fach';

  @override
  String get addFilter => 'Filter hinzufügen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get cancel => 'Abbrechen';

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

  @override
  String get search => 'Suchen...';

  @override
  String get date => 'Datum: ';

  @override
  String get updated => 'Aktualisiert: ';

  @override
  String get dateP => 'Datum';

  @override
  String get updatedP => 'Aktualisiert';

  @override
  String get day => 'Tag';

  @override
  String get additionalInformation => 'Zusätzliche Informationen';

  @override
  String get planDetails => 'Plan Details';

  @override
  String get fetchedAt => 'Erster Fetch';

  @override
  String get lastFetchedAt => 'Letzter Fetch';

  @override
  String get settings => 'Einstellungen';

  @override
  String get credentials => 'Benutzerdaten';

  @override
  String get credentialsExp => 'Benutzerdaten für DSB';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort verstecken';

  @override
  String get credentialsSaved => 'Benutzerdaten gespeichert';

  @override
  String get username => 'Benutzername';

  @override
  String get usernameHint => 'z.B. 187801';

  @override
  String get password => 'Passwort';

  @override
  String get passwordHint => 'Gib dein Passwort ein';

  @override
  String get save => 'Speichern';

  @override
  String get notificationsExp => 'Benachrichtigungen bei neuen Einträgen';

  @override
  String get enhanceEntries => 'Einträge verbessern';

  @override
  String get filters => 'Filter';

  @override
  String get filtersExp => 'Filtern nach Klasse und Stunden';

  @override
  String get language => 'Sprache';

  @override
  String get languageExp => 'Die Sprache der App';

  @override
  String get filter => 'Filter';

  @override
  String get classFilter => 'Klassenfilter';

  @override
  String get classFilterHint => 'z.B. 10a';

  @override
  String get advancedFilters => 'Erweiterte Filter';

  @override
  String get help => 'Hilfe';

  @override
  String get cleanup => 'Bereinigung';

  @override
  String get simplifyEntries => 'Einträge vereinfachen';

  @override
  String get simplifyEntriesSub => 'Gedoppelte Einträge zusammenfassen';

  @override
  String get cleanupEntries => 'Einträge bereinigen';

  @override
  String get cleanupEntriesSub => 'Einträge besser lesbar machen';

  @override
  String get cleanupOptions => 'Bereinigungsoptionen';

  @override
  String get simplifyClassNames => 'Klassennamen vereinfachen';

  @override
  String get collapseClassNames => 'Klassennamen kollabieren';

  @override
  String get simplifyLessonStatus => 'Unterrichtsstatus vereinfachen';

  @override
  String get simplifyCourses => 'Kurse vereinfachen';

  @override
  String get mergeTutorCourses => 'Tutorenkurse zusammenfassen';

  @override
  String get renameSubjects => 'Fächer umbenennen';

  @override
  String get removeCourseNumbers => 'Kursnummern entfernen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get workManager => 'Periodische Überprüfungen';

  @override
  String get workManagerDesc =>
      'In festen Zeitabständen nach neuen Plänen suchen';

  @override
  String get backgroundCheckSchedule => 'Hintergrund Zeitplan';

  @override
  String get startTime => 'Anfangszeit';

  @override
  String get endTime => 'Endzeit';

  @override
  String get days => 'Wochentage';

  @override
  String get interval => 'Intervall';

  @override
  String get appearance => 'Aussehen';

  @override
  String get appTheme => 'App-Thema';

  @override
  String get themeColor => 'Themenfarbe';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get darkTheme => 'Dunkles Thema';

  @override
  String get standard => 'Standard';

  @override
  String get amoled => 'AMOLED';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get dynamicc => 'Dynamisch';

  @override
  String get defaultt => 'Standard';

  @override
  String get select => 'Auswählen';

  @override
  String get customColor => 'Individuelle Farbe';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get substitution => 'Vertretung';

  @override
  String get cancelled => 'Entfall';

  @override
  String get classChanged => 'Unterricht geändert';

  @override
  String get specialAssignment => 'Sondereinsatz';

  @override
  String get roomSubstitution => 'Raum-Vertretung';

  @override
  String get event => 'Veranstaltung';

  @override
  String get despiteAbsence => 'Trotz Absenz';

  @override
  String get substituteLesson => 'Statt-Vertretung';

  @override
  String get supervision => 'Betreuung';

  @override
  String get rescheduling => 'Verlegung';

  @override
  String get subjectGerman => 'Deutsch';

  @override
  String get subjectDrama => 'Darstellendes Spiel';

  @override
  String get subjectFrench => 'Französisch';

  @override
  String get subjectSpanish => 'Spanisch';

  @override
  String get subjectLatin => 'Latein';

  @override
  String get subjectPhysics => 'Physik';

  @override
  String get subjectChemistry => 'Chemie';

  @override
  String get subjectBiology => 'Biologie';

  @override
  String get subjectPoliticsEconomics => 'PoWi';

  @override
  String get subjectMathematics => 'Mathematik';

  @override
  String get subjectMusic => 'Musik';

  @override
  String get subjectEthics => 'Ethik';

  @override
  String get subjectCatholicReligion => 'Reli Katholisch';

  @override
  String get subjectHistory => 'Geschichte';

  @override
  String get subjectProtestantReligion => 'Reli Evangelisch';

  @override
  String get subjectSports => 'Sport';

  @override
  String get subjectEnglish => 'Englisch';

  @override
  String get subjectArt => 'Kunst';

  @override
  String get subjectTutorCourse => 'Tutorenkurs';

  @override
  String get subjectChinese => 'Chinesisch';

  @override
  String get subjectComputerScience => 'Informatik';

  @override
  String get subjectGeography => 'Erdkunde';

  @override
  String get resources => 'Aushänge';

  @override
  String get noResourcesAvailable => 'Keine Aushänge vorhanden';

  @override
  String get couldNotLoadResources => 'Aushänge konnten nicht geladen werden';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get notificationsWereNotEnabled =>
      'Benachrichtigungen wurden nicht eingeschaltet';

  @override
  String get couldNotNotifications =>
      'Konnte Benachrichtigungen nicht einschalten:';

  @override
  String get finishSetup => 'Einrichtung abschließen';

  @override
  String get customizePlanner => 'Passe die App deinen Bedürfnissen an';

  @override
  String get filtersDesc => 'Filtere Einträge nach deiner Klasse und Kursen';

  @override
  String get notificationsDesc =>
      'Erhalte Benachrichtigungen bei relevanten Einträgen';

  @override
  String get notificationsEnabled => 'Benachrichtigungen sind aktiviert';

  @override
  String get notificationsNotEnabled =>
      'Benachrichtigungen sind NICHT aktiviert';

  @override
  String get enable => 'Aktivieren';

  @override
  String get appearanceDesc => 'Passe das Aussehen der App an';

  @override
  String get completeSetup => 'Abschließen';

  @override
  String get youCanChangeSettings =>
      'Du kannst diese Einstellungen später noch ändern';

  @override
  String get checkingPermission =>
      'Überprüfe Benachrichtigungsberechtigungen...';

  @override
  String get notificationsAllowed => 'Benachrichtigungen sind genehmigt';

  @override
  String get notificationsNotAllowed =>
      'Benachrichtigungen sind NICHT genehmigt';

  @override
  String get notificationsCanBeSent =>
      'Die App kann Benachrichtigungen anzeigen';

  @override
  String get allowNotificationsExp =>
      'Erlaube Benachrichtigungen um bei neuen Einträgen benachrichtigt zu werden';

  @override
  String get requesting => 'Anfrage...';

  @override
  String get allowNotifications => 'Benachrichtigungen erlauben';
}
