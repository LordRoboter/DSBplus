import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/timetables/model/timetable.dart';
import 'package:planner/core/database/providers/database_provider.dart';
import 'package:planner/features/timetables/data/timetable_repository.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(
    ref.watch(databaseProvider),
    ref.watch(authRepositoryProvider),
  );
});

class TimetableNotifier extends AsyncNotifier<List<Timetable>> {
  late final TimetableRepository repository;

  @override
  Future<List<Timetable>> build() async {
    repository = ref.read(timetableRepositoryProvider);

    final cached = await repository.loadAll();

    _syncAfterInitialLoad(cached);

    return cached;
  }

  Future<void> _syncAfterInitialLoad(List<Timetable> cached) async {
    await Future<void>.delayed(Duration.zero);
    refresh();
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
