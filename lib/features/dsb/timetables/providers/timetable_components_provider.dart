import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/database/providers/database_provider.dart';
import 'package:planner/features/dsb/timetables/data/dsb_timetable_parser.dart';
import 'package:planner/features/dsb/timetables/data/timetable_merger.dart';
import 'package:planner/features/dsb/timetables/data/timetable_repository.dart';

final timetableParserProvider = Provider<DsbTimetableParser>((ref) {
  return DsbTimetableParser();
});

final timetableMergerProvider = Provider<TimetableMerger>((ref) {
  return TimetableMerger();
});

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(databaseProvider));
});
