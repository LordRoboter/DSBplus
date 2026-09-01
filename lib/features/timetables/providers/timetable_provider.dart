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

    ref.read(timetableRefreshingProvider.notifier).setRefreshing(true);

    try {
      final newData = await repository.sync(oldTimetables);
      state = AsyncValue.data(newData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      ref.read(timetableRefreshingProvider.notifier).setRefreshing(false);
    }
  }
}

final timetableProvider =
    AsyncNotifierProvider<TimetableNotifier, List<Timetable>>(
      TimetableNotifier.new,
    );

class TimetableRefreshingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setRefreshing(bool value) {
    state = value;
  }
}

final timetableRefreshingProvider =
    NotifierProvider<TimetableRefreshingNotifier, bool>(
      TimetableRefreshingNotifier.new,
    );
