import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:planner/core/util/lessons.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';

class DsbTimetableParser {
  final List<String> tableMapper;

  late final int classIndex;

  DsbTimetableParser({
    this.tableMapper = const [
      'type',
      'lesson',
      'teacher',
      'subject',
      'room',
      'text',
    ],
  }) {
    classIndex = tableMapper.indexOf('class');
  }

  List<Timetable> parse(String html, {required DateTime fetchedAt}) {
    final document = html_parser.parse(html);

    final tables = document.querySelectorAll('.mon_list');
    final headers = document.querySelectorAll('.mon_head');
    final titles = document.querySelectorAll('.mon_title');
    final infos = document.querySelectorAll('td.info');

    final results = <Timetable>[];

    for (int t = 0; t < tables.length; t++) {
      // Be defensive in case the HTML is malformed.
      if (t >= titles.length || t >= headers.length) {
        continue;
      }

      final timetable = _parseTable(
        table: tables[t],
        header: headers[t],
        title: titles[t],
        infos: infos,
        fetchedAt: fetchedAt,
      );

      results.add(timetable);
    }

    return results;
  }

  Timetable _parseTable({
    required Element table,
    required Element header,
    required Element title,
    required List<Element> infos,
    required DateTime fetchedAt,
  }) {
    final timetable = Timetable(
      entries: [],
      firstFetched: fetchedAt,
      lastFetched: fetchedAt,
    );

    _parseMetadata(
      timetable: timetable,
      title: title,
      header: header,
      infos: infos,
    );

    _parseRows(timetable: timetable, rows: table.querySelectorAll('tr'));

    return timetable;
  }

  void _parseMetadata({
    required Timetable timetable,
    required Element title,
    required Element header,
    required List<Element> infos,
  }) {
    final titleText = title.text.trim();
    final split = titleText.split(RegExp(r'\s+'));

    if (split.isNotEmpty) {
      final date = _tryParseDate(split.first);

      if (date != null) {
        timetable.date = date;
      }
    }

    final day = split.length > 1 ? split[1].replaceAll(',', '') : null;

    timetable.day = parseWeekday(day);

    final match = RegExp(
      r'Stand:\s*([\d.]+\s+\d{2}:\d{2})',
    ).firstMatch(header.text);

    final updated = match?.group(1);

    if (updated != null) {
      final updatedDate = _tryParseDateTime(updated);

      if (updatedDate != null) {
        timetable.updated = updatedDate;
      }
    }

    _parseInfos(timetable: timetable, infos: infos);
  }

  void _parseInfos({
    required Timetable timetable,
    required List<Element> infos,
  }) {
    final Map<String, String> extraInfos = {};

    String field = '';

    for (int i = 0; i < infos.length; i++) {
      try {
        if (i.isEven) {
          field = infos[i].text.trim();
          continue;
        }

        final value = infos[i].text.trim();

        final normalizedField = field
            .replaceFirst(RegExp(r'&.*'), '')
            .toLowerCase()
            .trim();

        if (normalizedField == 'unterrichtsfrei') {
          final entry = TimetableEntry(
            lesson: parseLesson(value),
            type: TimetableStatusType.cancelled,
          );

          timetable.entries.add(
            ClassEntry(classNames: ['Alle'], entries: [entry]),
          );
        } else {
          extraInfos[field] = value;
        }
      } catch (_) {
        // Ignore malformed info fields.
      }
    }

    timetable.extraInfos = extraInfos;
  }

  void _parseRows({required Timetable timetable, required List<Element> rows}) {
    var currentClass = 'Unknown';

    for (int r = 1; r < rows.length; r++) {
      final cells = rows[r].querySelectorAll('td');

      if (cells.length == 1) {
        currentClass = cells.first.text.trim().split(' ').first;
        continue;
      }

      if (cells.length < 2) {
        continue;
      }

      final classes = _getClasses(cells: cells, fallbackClass: currentClass);

      for (final className in classes) {
        final entry = TimetableEntry(
          lesson: parseLesson(valueFor('lesson', cells)),
          teacher: valueFor('teacher', cells),
          subject: valueFor('subject', cells),
          room: valueFor('room', cells),
          type: parseStatus(valueFor('type', cells)),
          text: valueFor('text', cells),
        );

        _addEntry(timetable: timetable, className: className, entry: entry);
      }
    }
  }

  List<String> _getClasses({
    required List<Element> cells,
    required String fallbackClass,
  }) {
    if (classIndex == -1 || classIndex >= cells.length) {
      return [fallbackClass];
    }

    final value = cells[classIndex].text.trim();

    if (value.isEmpty) {
      return [fallbackClass];
    }

    return value.split(', ');
  }

  void _addEntry({
    required Timetable timetable,
    required String className,
    required TimetableEntry entry,
  }) {
    final existing = timetable.entries
        .where((e) => e.classNames.contains(className))
        .firstOrNull;

    if (existing != null) {
      existing.entries.add(entry);
      return;
    }

    timetable.entries.add(
      ClassEntry(classNames: [className], entries: [entry]),
    );
  }

  String? valueFor(String key, List<Element> cells) {
    final index = tableMapper.indexOf(key);

    if (index == -1 || index >= cells.length) {
      return null;
    }

    final text = cells[index].text.trim();

    return text.isEmpty || text == '---' ? null : text;
  }

  DateTime? _tryParseDate(String value) {
    try {
      return DateFormat('dd.MM.yyyy', 'de_DE').parse(value);
    } catch (_) {
      return null;
    }
  }

  DateTime? _tryParseDateTime(String value) {
    try {
      return DateFormat('dd.MM.yyyy HH:mm', 'de_DE').parse(value);
    } catch (_) {
      return null;
    }
  }
}
