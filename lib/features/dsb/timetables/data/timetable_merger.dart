import 'package:planner/features/dsb/timetables/model/timetable.dart';

class TimetableMerger {
  const TimetableMerger();

  List<Timetable> merge(List<Timetable> timetables) {
    return _mergeByDate(timetables).map((timetable) {
      final mergedClasses = _mergeClasses(timetable.entries);

      final mergedLessons = mergedClasses.map((classEntry) {
        return classEntry.copyWith(entries: _mergeLessons(classEntry.entries));
      }).toList();

      final combined = _combineCommonLessons(mergedLessons);

      return timetable.copyWith(entries: combined);
    }).toList();
  }

  List<Timetable> _mergeByDate(List<Timetable> timetables) {
    final result = <String, Timetable>{};

    for (final timetable in timetables) {
      final key =
          '${timetable.date?.year}-'
          '${timetable.date?.month}-'
          '${timetable.date?.day}-'
          '${timetable.day}';

      final existing = result[key];

      if (existing == null) {
        result[key] = timetable;
        continue;
      }

      existing.entries.addAll(timetable.entries);

      if (timetable.firstFetched != null &&
          (existing.firstFetched == null ||
              timetable.firstFetched!.isBefore(existing.firstFetched!))) {
        existing.firstFetched = timetable.firstFetched;
      }

      if (timetable.lastFetched != null &&
          (existing.lastFetched == null ||
              timetable.lastFetched!.isAfter(existing.lastFetched!))) {
        existing.lastFetched = timetable.lastFetched;
      }
    }

    return result.values.toList();
  }

  List<ClassEntry> _mergeClasses(List<ClassEntry> entries) {
    final result = <String, ClassEntry>{};

    for (final entry in entries) {
      final classes = [...entry.classNames]..sort();
      final key = classes.join(',');

      final existing = result[key];

      if (existing != null) {
        existing.entries.addAll(entry.entries);
      } else {
        result[key] = ClassEntry(
          classNames: classes,
          entries: [...entry.entries],
        );
      }
    }

    return result.values.toList();
  }

  List<TimetableEntry> _mergeLessons(List<TimetableEntry> entries) {
    if (entries.isEmpty) {
      return [];
    }

    final sorted = [...entries];

    sorted.sort((a, b) {
      final aLesson = _firstLesson(a.lesson);
      final bLesson = _firstLesson(b.lesson);

      if (aLesson == null && bLesson == null) return 0;
      if (aLesson == null) return 1;
      if (bLesson == null) return -1;

      return aLesson.compareTo(bLesson);
    });

    final result = <TimetableEntry>[];

    for (final current in sorted) {
      if (result.isEmpty) {
        result.add(current);
        continue;
      }

      final previous = result.last;

      final sameProperties =
          previous.teacher == current.teacher &&
          previous.subject == current.subject &&
          previous.type == current.type;

      final connected = _areConnected(previous.lesson, current.lesson);

      if (sameProperties && connected) {
        final mergedLessons = {
          ...?previous.lesson?.lessons,
          ...?current.lesson?.lessons,
        };

        result[result.length - 1] = previous.copyWith(
          lesson: LessonRange(mergedLessons),
          room: previous.room ?? current.room,
          text: previous.text ?? current.text,
        );
      } else {
        result.add(current);
      }
    }

    return result;
  }

  List<ClassEntry> _combineCommonLessons(List<ClassEntry> classEntries) {
    final lessons = <String, _LessonGroup>{};

    for (final classEntry in classEntries) {
      for (final lesson in classEntry.entries) {
        final lessonKey = [
          lesson.lesson,
          lesson.subject,
          lesson.teacher,
          lesson.room,
          lesson.type,
          lesson.text,
        ].join('|');

        final group = lessons.putIfAbsent(
          lessonKey,
          () => _LessonGroup(lesson),
        );

        group.classes.addAll(classEntry.classNames);
      }
    }

    final result = <String, ClassEntry>{};

    for (final group in lessons.values) {
      final classes = group.classes.toSet().toList()..sort();
      final classKey = classes.join(',');

      final existing = result[classKey];

      if (existing != null) {
        existing.entries.add(group.lesson);
      } else {
        result[classKey] = ClassEntry(
          classNames: classes,
          entries: [group.lesson],
        );
      }
    }

    return result.values.toList();
  }

  int? _firstLesson(LessonRange? lesson) {
    if (lesson == null || lesson.lessons.isEmpty) {
      return null;
    }

    return lesson.lessons.reduce((a, b) => a < b ? a : b);
  }

  bool _areConnected(LessonRange? first, LessonRange? second) {
    if (first == null || second == null) {
      return false;
    }

    if (first.lessons.isEmpty || second.lessons.isEmpty) {
      return false;
    }

    final firstEnd = first.lessons.reduce((a, b) => a > b ? a : b);

    final secondStart = second.lessons.reduce((a, b) => a < b ? a : b);

    return secondStart == firstEnd + 1;
  }
}

class _LessonGroup {
  final TimetableEntry lesson;
  final List<String> classes = [];

  _LessonGroup(this.lesson);
}
