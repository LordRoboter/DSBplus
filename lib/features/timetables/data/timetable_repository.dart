import 'package:drift/drift.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/timetables/model/timetable.dart';
import 'package:planner/core/database/database.dart'
    show
        AppDatabase,
        TimetablesCompanion,
        ClassEntriesCompanion,
        TimetableEntriesCompanion;
import 'package:planner/core/database/database.dart' as model;
import 'package:planner/features/timetables/data/dsb_api.dart';
import 'package:collection/collection.dart';

class TimetableRepository {
  final AppDatabase db;
  final AuthRepository auth;

  TimetableRepository(this.db, this.auth);

  Future<int> save(Timetable timetable) async {
    return db.transaction(() async {
      final existing = await _findExisting(timetable);

      if (existing != null) {
        await _deleteTimetable(existing.id);
      }

      return _insert(timetable);
    });
  }

  Future<void> _deleteTimetable(int id) async {
    await (db.delete(db.timetables)..where((t) => t.id.equals(id))).go();
  }

  Future<List<int>> _saveAll(List<Timetable> timetables) async {
    final ids = <int>[];

    for (final timetable in timetables) {
      final existing = await _findExisting(timetable);

      if (existing != null) {
        await _deleteTimetable(existing.id);
      }

      ids.add(await _insert(timetable));
    }

    return ids;
  }

  Future<List<int>> saveAll(List<Timetable> timetables) {
    return db.transaction(() => _saveAll(timetables));
  }

  Future<model.Timetable?> _findExisting(Timetable timetable) async {
    final query = db.select(db.timetables);

    query.where((t) {
      final dateCondition = timetable.date == null
          ? t.date.isNull()
          : t.date.equals(timetable.date!);

      final dayCondition = timetable.day == null
          ? t.day.isNull()
          : t.day.equalsValue(timetable.day!);

      return dateCondition & dayCondition;
    });

    return query.getSingleOrNull();
  }

  Future<int> _insert(Timetable timetable) async {
    final timetableId = await db
        .into(db.timetables)
        .insert(
          TimetablesCompanion.insert(
            date: Value(timetable.date),
            day: Value(timetable.day),
            updated: Value(timetable.updated),
            firstFetched: Value(timetable.firstFetched),
            lastFetched: Value(timetable.lastFetched),
            extraInfos: Value(timetable.extraInfos),
          ),
        );

    for (final classEntry in timetable.entries) {
      final classEntryId = await db
          .into(db.classEntries)
          .insert(
            ClassEntriesCompanion.insert(
              timetableId: timetableId,
              classNames: classEntry.classNames,
            ),
          );

      for (final entry in classEntry.entries) {
        await db
            .into(db.timetableEntries)
            .insert(
              TimetableEntriesCompanion.insert(
                classEntryId: classEntryId,
                lesson: Value(entry.lesson),
                teacher: Value(entry.teacher),
                subject: Value(entry.subject),
                room: Value(entry.room),
                type: Value(entry.type),
                description: Value(entry.text),
              ),
            );
      }
    }

    return timetableId;
  }

  Future<Timetable?> load(int timetableId) async {
    final timetable = await (db.select(
      db.timetables,
    )..where((t) => t.id.equals(timetableId))).getSingleOrNull();

    if (timetable == null) {
      return null;
    }

    final classRows = await (db.select(
      db.classEntries,
    )..where((c) => c.timetableId.equals(timetableId))).get();

    final entries = <ClassEntry>[];

    for (final classRow in classRows) {
      final entryRows = await (db.select(
        db.timetableEntries,
      )..where((e) => e.classEntryId.equals(classRow.id))).get();

      entries.add(
        ClassEntry(
          classNames: classRow.classNames,
          entries: entryRows
              .map(
                (row) => TimetableEntry(
                  lesson: row.lesson,
                  teacher: row.teacher,
                  subject: row.subject,
                  room: row.room,
                  type: row.type,
                  text: row.description,
                ),
              )
              .toList(),
        ),
      );
    }

    return Timetable(
      date: timetable.date,
      day: timetable.day,
      updated: timetable.updated,
      firstFetched: timetable.firstFetched,
      lastFetched: timetable.lastFetched,
      extraInfos: timetable.extraInfos,
      entries: entries,
    );
  }

  Future<List<Timetable>> loadAll() async {
    final timetableRows = await db.select(db.timetables).get();
    final classEntryRows = await db.select(db.classEntries).get();
    final timetableEntryRows = await db.select(db.timetableEntries).get();

    final classEntriesByTimetable = <int, List<ClassEntry>>{};

    final classEntryModels = <int, ClassEntry>{};

    for (final row in classEntryRows) {
      final classEntry = ClassEntry(classNames: row.classNames, entries: []);

      classEntryModels[row.id] = classEntry;

      classEntriesByTimetable
          .putIfAbsent(row.timetableId, () => [])
          .add(classEntry);
    }

    for (final row in timetableEntryRows) {
      final classEntry = classEntryModels[row.classEntryId];

      if (classEntry == null) {
        continue;
      }

      classEntry.entries.add(
        TimetableEntry(
          lesson: row.lesson,
          teacher: row.teacher,
          subject: row.subject,
          room: row.room,
          type: row.type,
          text: row.description,
        ),
      );
    }

    return timetableRows.map((row) {
      return Timetable(
        date: row.date,
        day: row.day,
        updated: row.updated,
        firstFetched: row.firstFetched,
        lastFetched: row.lastFetched,
        extraInfos: row.extraInfos,
        entries: classEntriesByTimetable[row.id] ?? [],
      );
    }).toList();
  }

  Future<List<Timetable>> fetch() async {
    final username = await auth.getUsername();
    final password = await auth.getPassword();

    if (username == null || password == null) {
      throw StateError('DSB credentials are not configured');
    }

    final api = DSBApi(
      username,
      password,
      tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
    );

    var entries = await api.fetchEntries();
    return entries;

    /*entries = entries.map((newEntry) {
      final existingEntry = oldEntries.firstWhereOrNull(
        (old) =>
            old.date?.year == newEntry.date?.year &&
            old.date?.month == newEntry.date?.month &&
            old.date?.day == newEntry.date?.day &&
            old.day == newEntry.day,
      );

      if (existingEntry != null) {
        return newEntry.copyWith(firstFetched: existingEntry.firstFetched);
      }
      return newEntry;
    }).toList();

    const equality = DeepCollectionEquality();

    final changed = !equality.equals(
      oldEntries.map((e) => e.toComparableJson()).toList(),
      entries.map((e) => e.toComparableJson()).toList(),
    );

    await validateSelectedDayDate(
      entries
          .map((e) {
            return formatDayDate(e);
          })
          .toSet()
          .toList(),
    );

    await saveEntries(entries);

    if (changed) {
      _updates.add(null);
    }

    await saveUpdated(
      DateFormat('dd.MM. HH:mm', 'de_DE').format(DateTime.now()),
    );

    return oldEntries;*/
  }

  Future<List<Timetable>> sync(List<Timetable> oldTimetables) async {
    var newTimetables = await fetch();

    newTimetables = newTimetables.map((newTimetable) {
      final existingTimetable = oldTimetables.firstWhereOrNull(
        (old) =>
            old.date?.year == newTimetable.date?.year &&
            old.date?.month == newTimetable.date?.month &&
            old.date?.day == newTimetable.date?.day &&
            old.day == newTimetable.day,
      );

      if (existingTimetable != null) {
        return newTimetable.copyWith(
          firstFetched: existingTimetable.firstFetched,
        );
      }

      return newTimetable;
    }).toList();

    final newKeys = newTimetables
        .map((t) => _timetableKey(date: t.date, day: t.day))
        .toSet();

    await db.transaction(() async {
      final existingRows = await db.select(db.timetables).get();

      for (final existing in existingRows) {
        final key = _timetableKey(date: existing.date, day: existing.day);

        if (!newKeys.contains(key)) {
          await _deleteTimetable(existing.id);
        }
      }

      await _saveAll(newTimetables);
    });

    return newTimetables;
  }

  Future<void> clear() async {
    await db.transaction(() async {
      await db.delete(db.timetableEntries).go();
      await db.delete(db.classEntries).go();
      await db.delete(db.timetables).go();
    });
  }

  String _timetableKey({required DateTime? date, required dynamic day}) {
    return '${date?.year}-${date?.month}-${date?.day}-$day';
  }
}
