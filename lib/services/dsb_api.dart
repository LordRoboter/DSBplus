import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:planner/core/model/timetable.dart';
import 'package:planner/core/util/lessons.dart';
import 'package:uuid/uuid.dart';

import 'package:intl/intl.dart';

//TODO: Get additional resources (Aushänge/ Infos/ ...) -> GetData on normal website, .....
class DSBApi {
  static const String dataUrl =
      "https://app.dsbcontrol.de/JsonHandler.ashx/GetData";

  final String username;
  final String password;

  final List<String> tableMapper;

  late final int classIndex;

  DSBApi(
    this.username,
    this.password, {
    this.tableMapper = const [
      "type",
      "class",
      "lesson",
      "subject",
      "room",
      "new_subject",
      "new_teacher",
      "teacher",
    ],
  }) {
    classIndex = tableMapper.indexOf("class");
  }

  Future<List<Timetable>> fetchEntries() async {
    final fetchedAt = DateTime.now();
    final now = fetchedAt.toUtc().toIso8601String();

    final params = {
      "UserId": username,
      "UserPw": password,
      "AppVersion": "2.5.9",
      "Language": "de",
      "OsVersion": "28 8.0",
      "AppId": const Uuid().v4(),
      "Device": "SM-G930F",
      "BundleId": "de.heinekingmedia.dsbmobile",
      "Date": now,
      "LastUpdate": now,
    };

    final compressed = gzip.encode(utf8.encode(jsonEncode(params)));

    final encoded = base64Encode(compressed);

    final response = await http.post(
      Uri.parse(dataUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "req": {"Data": encoded, "DataType": 1},
      }),
    );

    final jsonResponse = jsonDecode(response.body);

    final decoded = base64Decode(jsonResponse["d"]);

    final decompressed = utf8.decode(gzip.decode(decoded));

    final data = jsonDecode(decompressed);

    if (data["Resultcode"] != 0) {
      throw Exception(data["ResultStatusInfo"]);
    }

    List<String> urls = [];

    for (final page in data["ResultMenuItems"][0]["Childs"]) {
      for (final child in page["Root"]["Childs"]) {
        if (child["Childs"] is List) {
          for (final sub in child["Childs"]) {
            urls.add(sub["Detail"]);
          }
        } else {
          urls.add(child["Childs"]["Detail"]);
        }
      }
    }

    final List<Timetable> output = [];

    for (final url in urls) {
      if (url.endsWith(".htm") &&
          !url.endsWith(".html") &&
          !url.endsWith("news.htm")) {
        final timetables = await fetchTimetable(url, fetchedAt);

        if (timetables != null) {
          output.addAll(timetables);
        }
      }
    }

    return mergeTimetables(output);
  }

  String? valueFor(String key, List<Element> cells) {
    final index = tableMapper.indexOf(key);

    if (index == -1 || index >= cells.length) {
      return null;
    }

    final text = cells[index].text.trim();
    return text.isEmpty || text == "---" ? null : text;
  }

  Future<List<Timetable>?> fetchTimetable(
    String url,
    DateTime fetchedAt,
  ) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (e) {
      debugPrint("GET failed: $url");
      debugPrint(e as String);
      return null;
    }

    final document = parse(response.body);

    final List<Timetable> results = [];

    final tables = document.querySelectorAll(".mon_list");

    final headers = document.querySelectorAll(".mon_head");

    final titles = document.querySelectorAll(".mon_title");

    final infos = document.querySelectorAll("td.info");

    for (int t = 0; t < tables.length; t++) {
      final timetable = Timetable(
        entries: [],
        firstFetched: fetchedAt,
        lastFetched: fetchedAt,
      );

      final title = titles[t].text.trim();

      final split = title.split(" ");

      final date = split.first;
      final inputFormat = DateFormat("dd.MM.yyyy", 'de_DE');
      final dateTime = inputFormat.parse(date);

      final day = split.length > 1 ? split[1].replaceAll(",", "") : null;

      final match = RegExp(
        r'Stand:\s*([\d.]+\s+\d{2}:\d{2})',
      ).firstMatch(headers[t].text);

      final updated = match?.group(1) ?? '';
      final updatedFormat = DateFormat("dd.MM.yyyy HH:mm", 'de_DE');
      final updatedDateTime = updatedFormat.parse(updated);

      final rows = tables[t].querySelectorAll("tr");

      var classs = "Unknown";

      //TODO: Display infos
      final Map<String, String> theInfos = {};

      var field = "";

      try {
        for (int i = 0; i < infos.length; i++) {
          if (i % 2 == 1) {
            if (field.replaceFirst(RegExp(r'&.*'), '').toLowerCase().trim() ==
                "unterrichtsfrei") {
              final entry = TimetableEntry(
                lesson: parseLesson(infos[i].text),
                type: TimetableStatusType.cancelled,
              );

              timetable.entries.add(
                ClassEntry(classNames: ["Alle"], entries: [entry]),
              );
            } else {
              theInfos[field] = infos[i].text;
            }
          } else {
            field = infos[i].text;
          }
        }
      } catch (e) {
        //This is what you call amazing error handling
      }

      timetable.date = dateTime;
      timetable.updated = updatedDateTime;
      timetable.day = parseWeekday(day);
      timetable.extraInfos = theInfos;

      for (int r = 1; r < rows.length; r++) {
        final cells = rows[r].querySelectorAll("td");

        if (cells.length == 1) {
          classs = cells[0].text.trim().split(" ")[0];
          continue;
        } else if (cells.length < 2) {
          continue;
        }

        List<String> classes = ["---"];

        if (classIndex != -1) {
          classes = cells[classIndex].text.split(", ");
        }

        for (final cls in classes) {
          final entry = TimetableEntry(
            lesson: parseLesson(valueFor("lesson", cells)),
            teacher: valueFor("teacher", cells),
            subject: valueFor("subject", cells),
            room: valueFor("room", cells),
            type: parseStatus(valueFor("type", cells)),
            text: valueFor("text", cells),
          );

          final existing = timetable.entries
              .where(
                (e) => e.classNames.contains(classIndex != -1 ? cls : classs),
              )
              .firstOrNull;

          if (existing != null) {
            existing.entries.add(entry);
          } else {
            timetable.entries.add(
              ClassEntry(
                classNames: classIndex != -1 ? [cls] : [classs],
                entries: [entry],
              ),
            );
          }
        }
      }
      results.add(timetable);
    }

    return results;
  }

  List<Timetable> mergeTimetables(List<Timetable> timetables) {
    List<Timetable> mergeByDate(List<Timetable> timetables) {
      final Map<String, Timetable> result = {};

      for (final timetable in timetables) {
        final key =
            "${timetable.date?.year}-${timetable.date?.month}-${timetable.date?.day}-${timetable.day}";

        if (!result.containsKey(key)) {
          result[key] = timetable;
        } else {
          final existing = result[key]!;

          existing.entries.addAll(timetable.entries);

          if (timetable.firstFetched != null &&
              (existing.firstFetched == null ||
                  timetable.firstFetched!.isBefore(existing.firstFetched!))) {
            existing.firstFetched = timetable.firstFetched;
          }

          if (timetable.lastFetched != null &&
              (existing.lastFetched == null ||
                  timetable.lastFetched!.isAfter(existing.lastFetched!))) {
            existing.lastFetched = timetable.lastFetched;
          }
        }
      }

      return result.values.toList();
    }

    List<ClassEntry> mergeClasses(List<ClassEntry> entries) {
      final Map<String, ClassEntry> result = {};

      for (final entry in entries) {
        final classes = [...entry.classNames]..sort();
        final key = classes.join(",");

        if (result.containsKey(key)) {
          result[key]!.entries.addAll(entry.entries);
        } else {
          result[key] = ClassEntry(
            classNames: classes,
            entries: [...entry.entries],
          );
        }
      }

      return result.values.toList();
    }

    List<ClassEntry> combineCommonLessons(List<ClassEntry> classEntries) {
      // First: invert class -> lessons into lesson -> classes
      final Map<String, _LessonGroup> lessons = {};

      for (final classEntry in classEntries) {
        for (final lesson in classEntry.entries) {
          final lessonKey = [
            lesson.lesson,
            lesson.subject,
            lesson.teacher,
            lesson.room,
            lesson.type,
            lesson.text,
          ].join("|");

          final group = lessons.putIfAbsent(
            lessonKey,
            () => _LessonGroup(lesson),
          );

          group.classes.addAll(classEntry.classNames);
        }
      }

      // Second: group identical class sets back together
      final Map<String, ClassEntry> result = {};

      for (final group in lessons.values) {
        final classes = group.classes.toSet().toList()..sort();

        final classKey = classes.join(",");

        final existing = result[classKey];

        if (existing != null) {
          existing.entries.add(group.lesson);
        } else {
          result[classKey] = ClassEntry(
            classNames: classes,
            entries: [group.lesson],
          );
        }
      }

      return result.values.toList();
    }

    return mergeByDate(timetables).map((timetable) {
      final mergedClasses = mergeClasses(timetable.entries);
      final simplified = combineCommonLessons(mergedClasses);

      return timetable.copyWith(entries: simplified);
    }).toList();
  }
}

class _LessonGroup {
  final TimetableEntry lesson;
  final List<String> classes = [];

  _LessonGroup(this.lesson);
}
