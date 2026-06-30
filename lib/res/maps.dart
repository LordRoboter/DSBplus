import 'package:flutter/material.dart';

const typeMap = {
  "eigenverantwortliches arbeiten": "Entfall",
  "veranst.": "Veranstaltung",
  "trotzabsenz": "Trotz Absenz",
  "sondereins.": "Sondereinsatz",
  "raum-vtr.": "Raum-Vertretung",
};

const subjectMap = {
  "d": "Deutsch",
  "f": "Französisch",
  "spa": "Spanisch",
  "lat": "Latein",
  "l": "Latein",
  "ph": "Physik",
  "ch": "Chemie",
  "bio": "Biologie",
  "powi": "PoWi",
  "m": "Mathematik",
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

Color typeColor(String type) {
  switch (type.toLowerCase()) {
    case "entfall" || "eigenverantwortliches arbeiten":
      return Colors.red.shade100;

    case "vertretung":
      return Colors.orange.shade100;

    case "unterricht geändert":
      return Colors.purple.shade100;

    case "sondereinsatz" || "sondereins.":
      return Colors.blue.shade50;

    case "raum-vertretung" || "raum-vtr.":
      return Colors.orange.shade50;

    case "veranstaltung" || "veranst.":
      return Colors.green.shade100;

    case "trotz absenz" || "trotzabsenz":
      return Colors.yellow.shade100;

    case "statt-vertretung":
      return Colors.amber.shade100;

    case "betreuung":
      return Colors.orangeAccent.shade100;

    default:
      return Colors.grey.shade200;
  }
}
