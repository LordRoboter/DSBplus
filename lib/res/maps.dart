import 'package:flutter/material.dart';
import 'package:planner/core/models/timetable.dart';
import 'package:planner/theme.dart';

const typeMap = {
  "eigenverantwortliches arbeiten": "Entfall",
  "veranst.": "Veranstaltung",
  "trotzabsenz": "Trotz Absenz",
  "sondereins.": "Sondereinsatz",
  "raum-vtr.": "Raum-Vertretung",
};

const subjectMap = {
  "d": "Deutsch",
  "ds": "Darstellendes Spiel",
  "f": "Französisch",
  "spa": "Spanisch",
  "lat": "Latein",
  "l": "Latein",
  "ph": "Physik",
  "ch": "Chemie",
  "bio": "Biologie",
  "powi": "PoWi",
  "m": "Mathematik",
  "mu": "Musik",
  "ethi": "Ethik",
  "rka": "Reli Katholisch",
  "g": "Geschichte",
  "rev": "Reli Evangelisch",
  "spo": "Sport",
  "e": "Englisch",
  "ku": "Kunst",
  "tut": "Tutorenkurs",
  "chin": "Chinesisch",
  "info": "Informatik",
  "geo": "Erdkunde",
};

const themeMap = {
  AppThemes.system: "System",
  AppThemes.light: "Hell",
  AppThemes.dark: "Dunkel",
};

Color typeColor(TimetableStatusType? type) {
  switch (type) {
    case TimetableStatusType.cancelled:
      return Colors.red.shade100;

    case TimetableStatusType.substitution:
      return Colors.orange.shade100;

    case TimetableStatusType.classChanged:
      return Colors.purple.shade100;

    case TimetableStatusType.specialAssignment:
      return Colors.blue.shade50;

    case TimetableStatusType.roomSubstitution:
      return Colors.orange.shade50;

    case TimetableStatusType.event:
      return Colors.green.shade100;

    case TimetableStatusType.despiteAbsence:
      return Colors.yellow.shade100;

    case TimetableStatusType.substituteLesson:
      return Colors.amber.shade100;

    case TimetableStatusType.supervision:
      return Colors.orangeAccent.shade100;

    default:
      return Colors.grey.shade200;
  }
}
