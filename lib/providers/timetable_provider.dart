import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/model/timetable.dart';
import 'package:planner/providers/database_provider.dart';
import 'package:planner/repo/timetable_repository.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(databaseProvider));
});

class TimetableNotifier extends AsyncNotifier<List<Timetable>> {
  @override
  Future<List<Timetable>> build() {
    return ref.read(timetableRepositoryProvider).loadAll();
  }

  Future<void> refresh() async {
    final oldTimetables = state.value ?? [];

    state = await AsyncValue.guard(
      () => ref.read(timetableRepositoryProvider).sync(oldTimetables),
    );
  }
}

final timetableProvider =
    AsyncNotifierProvider<TimetableNotifier, List<Timetable>>(
      TimetableNotifier.new,
    );
