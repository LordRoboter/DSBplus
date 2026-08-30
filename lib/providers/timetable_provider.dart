import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/model/timetable.dart';
import 'package:planner/providers/database_provider.dart';
import 'package:planner/repo/timetable_repository.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(databaseProvider));
});

class TimetableNotifier extends AsyncNotifier<List<Timetable>> {
  late final TimetableRepository repository;

  @override
  Future<List<Timetable>> build() {
    repository = ref.read(timetableRepositoryProvider);
    return repository.loadAll();
  }

  Future<void> refresh() async {
    final oldTimetables = state.value ?? [];

    state = AsyncLoading<List<Timetable>>().copyWithPrevious(state);

    try {
      final newData = await repository.sync(oldTimetables);
      state = AsyncData(newData);
    } catch (e, stack) {
      state = AsyncError<List<Timetable>>(e, stack).copyWithPrevious(state);
    }
  }
}

final timetableProvider =
    AsyncNotifierProvider<TimetableNotifier, List<Timetable>>(
      TimetableNotifier.new,
    );
