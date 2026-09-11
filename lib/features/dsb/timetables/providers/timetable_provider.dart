import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/dsb/provider/dsb_api_provider.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:planner/features/dsb/timetables/data/timetable_repository.dart';
import 'package:planner/features/dsb/timetables/providers/timetable_components_provider.dart';
import 'package:planner/features/dsb/timetables/service/dsb_timetable_service.dart';

final dsbTimetableServiceProvider = Provider<DsbTimetableService>((ref) {
  return DsbTimetableService(
    api: ref.watch(dsbApiProvider),
    parser: ref.watch(timetableParserProvider),
    merger: ref.watch(timetableMergerProvider),
    repository: ref.watch(timetableRepositoryProvider),
  );
});

class TimetableNotifier extends AsyncNotifier<List<Timetable>> {
  late final TimetableRepository repository;
  late final DsbTimetableService service;

  @override
  Future<List<Timetable>> build() async {
    repository = ref.read(timetableRepositoryProvider);
    service = ref.read(dsbTimetableServiceProvider);

    final cached = await repository.loadAll();

    Future.microtask(refresh);

    return cached;
  }

  Future<void> refresh() async {
    final background = state.value ?? [];

    ref.read(timetableRefreshingProvider.notifier).setRefreshing(true);

    try {
      final timetables = await service.sync(background: background);

      state = AsyncData(timetables);
    } catch (e, stack) {
      // Keep cached data if refresh fails.
      if (!state.hasValue) {
        state = AsyncError(e, stack);
      }
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
