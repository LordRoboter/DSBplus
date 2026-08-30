import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/timetables/model/daydate.dart';
import 'package:planner/features/timetables/model/timetable.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/core/util/sorter.dart';
import 'package:planner/core/providers/localization_provider.dart';
import 'package:planner/features/timetables/providers/timetable_provider.dart';

final enhancedTimetablesProvider = Provider<AsyncValue<List<Timetable>>>((ref) {
  final timetables = ref.watch(timetableProvider);
  final settings = ref.watch(settingsProvider);
  final localization = ref.watch(localizationProvider);

  return settings.when(
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
    data: (settings) {
      return localization.when(
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
        data: (localization) {
          return timetables.whenData((timetables) {
            return timetables.map((timetable) {
              return enhanceTimetable(
                localization,
                timetable,
                settings.clean,
                settings.simplify,
                disposeTut: settings.disposeTut,
                cleanClassNames: settings.cleanClassNames,
                remapTypes: settings.remapTypes,
                cleanupCourses: settings.cleanupCourses,
                disposeCourseNumbers: settings.disposeCourseNumbers,
                mapCourses: settings.mapCourses,
              );
            }).toList();
          });
        },
      );
    },
  );
});

final filteredEnhancedTimetablesProvider =
    Provider<AsyncValue<List<Timetable>>>((ref) {
      final timetables = ref.watch(timetableProvider);
      final settings = ref.watch(settingsProvider);
      final localizations = ref.watch(localizationProvider);

      return settings.when(
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
        data: (settings) {
          return localizations.when(
            loading: () => const AsyncLoading(),
            error: (error, stack) => AsyncError(error, stack),
            data: (localization) {
              return timetables.whenData((timetables) {
                var result = filterTimetables(timetables, [
                  settings.classFilter,
                ]);

                if (settings.filters.isNotEmpty) {
                  result = filterTimetables(result, settings.filters);
                }

                return result
                    .map(
                      (timetable) => enhanceTimetable(
                        localization,
                        timetable,
                        settings.clean,
                        settings.simplify,
                        disposeTut: settings.disposeTut,
                        cleanClassNames: settings.cleanClassNames,
                        remapTypes: settings.remapTypes,
                        cleanupCourses: settings.cleanupCourses,
                        disposeCourseNumbers: settings.disposeCourseNumbers,
                        mapCourses: settings.mapCourses,
                      ),
                    )
                    .toList();
              });
            },
          );
        },
      );
    });

final availableDayDatesProvider = Provider<AsyncValue<List<DayDate>>>((ref) {
  final timetables = ref.watch(timetableProvider);

  return timetables.whenData((timetables) {
    return computeAvailableDayDates(timetables);
  });
});
