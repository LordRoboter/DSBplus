import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/dsb/model/dsb_catalog.dart';
import 'package:planner/features/dsb/model/dsb_page.dart';
import 'package:planner/features/dsb/data/dsb_json_parser.dart';
import 'package:uuid/uuid.dart';

class DsbApi {
  static const String dataUrl =
      'https://app.dsbcontrol.de/JsonHandler.ashx/GetData';

  final AuthRepository auth;

  final DsbJsonParser jsonParser;

  DsbApi(this.auth, {this.jsonParser = const DsbJsonParser()});

  Future<DsbCatalog> loadCatalog() async {
    return DsbCatalog(pages: await fetchPages());
  }

  Future<List<DsbPage>> fetchPages() async {
    final data = await _requestData();

    return jsonParser.parsePages(data);
  }

  Future<Map<String, dynamic>> _requestData() async {
    final username = await auth.getUsername();
    final password = await auth.getPassword();

    if (username == null || password == null) {
      throw StateError('DSB credentials are not configured');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final params = {
      'UserId': username,
      'UserPw': password,
      'AppVersion': '2.5.9',
      'Language': 'de',
      'OsVersion': '28 8.0',
      'AppId': const Uuid().v4(),
      'Device': 'SM-G930F',
      'BundleId': 'de.heinekingmedia.dsbmobile',
      'Date': now,
      'LastUpdate': now,
    };

    final compressed = gzip.encode(utf8.encode(jsonEncode(params)));

    final encoded = base64Encode(compressed);

    final response = await http.post(
      Uri.parse(dataUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'req': {'Data': encoded, 'DataType': 1},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'DSB request failed with status ${response.statusCode}',
      );
    }

    final responseJson = jsonDecode(response.body);

    final encodedData = responseJson['d'];

    if (encodedData is! String) {
      throw const FormatException(
        'DSB response does not contain valid encoded data.',
      );
    }

    final decoded = base64Decode(encodedData);
    final decompressed = utf8.decode(gzip.decode(decoded));

    final data = jsonDecode(decompressed);

    if (data is! Map<String, dynamic>) {
      throw const FormatException('DSB response is not a JSON object.');
    }

    return data;
  }

  Future<String?> fetchPage(String url) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (e) {
      debugPrint("GET failed: $url");
      debugPrint(e as String);
      return null;
    }
    return response.body;
  }
}
