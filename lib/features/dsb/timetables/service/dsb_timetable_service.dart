import 'package:planner/features/dsb/data/dsb_api.dart';
import 'package:planner/features/dsb/timetables/data/dsb_timetable_parser.dart';
import 'package:planner/features/dsb/timetables/data/timetable_merger.dart';
import 'package:planner/features/dsb/timetables/data/timetable_repository.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:collection/collection.dart';

class DsbTimetableService {
  final DsbApi api;
  final TimetableRepository repository;
  final DsbTimetableParser parser;
  final TimetableMerger merger;

  DsbTimetableService({
    required this.api,
    required this.repository,
    required this.parser,
    required this.merger,
  });

  Future<List<Timetable>> sync({required List<Timetable> background}) async {
    final catalog = await api.loadCatalog();

    final downloaded = <Timetable>[];

    for (final page in catalog.timetables) {
      for (final subPage in page.childs) {
        final html = await api.fetchPage(subPage.url);

        if (html != null) {
          final timetables = parser.parse(html, fetchedAt: DateTime.now());

          downloaded.addAll(timetables);
        }
      }
    }

    final merged = merger.merge(downloaded);

    final synced = _mergeWithBackground(background: background, fresh: merged);
    await repository.saveAll(synced);

    return synced;
  }

  List<Timetable> _mergeWithBackground({
    required List<Timetable> background,
    required List<Timetable> fresh,
  }) {
    return fresh.map((newTimetable) {
      final old = background.firstWhereOrNull(
        (old) => old.date == newTimetable.date && old.day == newTimetable.day,
      );

      if (old == null) {
        return newTimetable;
      }

      return newTimetable.copyWith(firstFetched: old.firstFetched);
    }).toList();
  }
}
