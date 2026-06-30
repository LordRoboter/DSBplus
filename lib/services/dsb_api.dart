import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:uuid/uuid.dart';

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

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    final now = DateTime.now().toUtc().toIso8601String();

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

    List<Map<String, dynamic>> output = [];

    for (final url in urls) {
      if (url.endsWith(".htm") &&
          !url.endsWith(".html") &&
          !url.endsWith("news.htm")) {
        output.addAll(await fetchTimetable(url));
      }
    }

    return output;
  }

  Future<List<Map<String, dynamic>>> fetchTimetable(String url) async {
    final response = await http.get(Uri.parse(url));

    final document = parse(response.body);

    final results = <Map<String, dynamic>>[];

    final tables = document.querySelectorAll(".mon_list");

    final headers = document.querySelectorAll(".mon_head");

    final titles = document.querySelectorAll(".mon_title");

    for (int t = 0; t < tables.length; t++) {
      final title = titles[t].text.trim();

      final split = title.split(" ");

      final date = split.first;

      final day = split.length > 1 ? split[1].replaceAll(",", "") : "";

      final updated = headers[t].text.replaceAll("Stand:", "").trim();

      final rows = tables[t].querySelectorAll("tr");

      var classs = "Unknown";

      for (int r = 1; r < rows.length; r++) {
        final cells = rows[r].querySelectorAll("td");

        if (cells.length == 1) {
          classs = cells[0].text.trim();
          continue;
        } else if (cells.length < 2) {
          continue;
        }

        List<String> classes = ["---"];

        if (classIndex != -1) {
          classes = cells[classIndex].text.split(", ");
        }

        for (final cls in classes) {
          Map<String, dynamic> entry = {
            "date": date,
            "day": day,
            "class": classs,
            "updated": updated,
          };

          for (int i = 0; i < cells.length; i++) {
            final key = i < tableMapper.length ? tableMapper[i] : "col$i";

            final value = cells[i].text.trim().isEmpty
                ? "---"
                : cells[i].text.trim();

            entry[key] = key == "class" ? cls : value;
          }

          results.add(entry);
        }
      }
    }

    return results;
  }
}
