// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TimetablesTable extends Timetables
    with TableInfo<$TimetablesTable, Timetable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weekday?, String> day =
      GeneratedColumn<String>(
        'day',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Weekday?>($TimetablesTable.$converterdayn);
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstFetchedMeta = const VerificationMeta(
    'firstFetched',
  );
  @override
  late final GeneratedColumn<DateTime> firstFetched = GeneratedColumn<DateTime>(
    'first_fetched',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
    'last_fetched',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>?, String>
  extraInfos = GeneratedColumn<String>(
    'extra_infos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, String>?>($TimetablesTable.$converterextraInfosn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    day,
    updated,
    firstFetched,
    lastFetched,
    extraInfos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetables';
  @override
  VerificationContext validateIntegrity(
    Insertable<Timetable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    }
    if (data.containsKey('first_fetched')) {
      context.handle(
        _firstFetchedMeta,
        firstFetched.isAcceptableOrUnknown(
          data['first_fetched']!,
          _firstFetchedMeta,
        ),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Timetable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Timetable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      day: $TimetablesTable.$converterdayn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day'],
        ),
      ),
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      firstFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_fetched'],
      ),
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched'],
      ),
      extraInfos: $TimetablesTable.$converterextraInfosn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extra_infos'],
        ),
      ),
    );
  }

  @override
  $TimetablesTable createAlias(String alias) {
    return $TimetablesTable(attachedDatabase, alias);
  }

  static TypeConverter<Weekday, String> $converterday =
      const WeekdayConverter();
  static TypeConverter<Weekday?, String?> $converterdayn =
      NullAwareTypeConverter.wrap($converterday);
  static TypeConverter<Map<String, String>, String> $converterextraInfos =
      const StringMapConverter();
  static TypeConverter<Map<String, String>?, String?> $converterextraInfosn =
      NullAwareTypeConverter.wrap($converterextraInfos);
}

class Timetable extends DataClass implements Insertable<Timetable> {
  final int id;
  final DateTime? date;
  final Weekday? day;
  final DateTime? updated;
  final DateTime? firstFetched;
  final DateTime? lastFetched;
  final Map<String, String>? extraInfos;
  const Timetable({
    required this.id,
    this.date,
    this.day,
    this.updated,
    this.firstFetched,
    this.lastFetched,
    this.extraInfos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<String>($TimetablesTable.$converterdayn.toSql(day));
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    if (!nullToAbsent || firstFetched != null) {
      map['first_fetched'] = Variable<DateTime>(firstFetched);
    }
    if (!nullToAbsent || lastFetched != null) {
      map['last_fetched'] = Variable<DateTime>(lastFetched);
    }
    if (!nullToAbsent || extraInfos != null) {
      map['extra_infos'] = Variable<String>(
        $TimetablesTable.$converterextraInfosn.toSql(extraInfos),
      );
    }
    return map;
  }

  TimetablesCompanion toCompanion(bool nullToAbsent) {
    return TimetablesCompanion(
      id: Value(id),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      updated: updated == null && nullToAbsent
          ? const Value.absent()
          : Value(updated),
      firstFetched: firstFetched == null && nullToAbsent
          ? const Value.absent()
          : Value(firstFetched),
      lastFetched: lastFetched == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetched),
      extraInfos: extraInfos == null && nullToAbsent
          ? const Value.absent()
          : Value(extraInfos),
    );
  }

  factory Timetable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Timetable(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime?>(json['date']),
      day: serializer.fromJson<Weekday?>(json['day']),
      updated: serializer.fromJson<DateTime?>(json['updated']),
      firstFetched: serializer.fromJson<DateTime?>(json['firstFetched']),
      lastFetched: serializer.fromJson<DateTime?>(json['lastFetched']),
      extraInfos: serializer.fromJson<Map<String, String>?>(json['extraInfos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime?>(date),
      'day': serializer.toJson<Weekday?>(day),
      'updated': serializer.toJson<DateTime?>(updated),
      'firstFetched': serializer.toJson<DateTime?>(firstFetched),
      'lastFetched': serializer.toJson<DateTime?>(lastFetched),
      'extraInfos': serializer.toJson<Map<String, String>?>(extraInfos),
    };
  }

  Timetable copyWith({
    int? id,
    Value<DateTime?> date = const Value.absent(),
    Value<Weekday?> day = const Value.absent(),
    Value<DateTime?> updated = const Value.absent(),
    Value<DateTime?> firstFetched = const Value.absent(),
    Value<DateTime?> lastFetched = const Value.absent(),
    Value<Map<String, String>?> extraInfos = const Value.absent(),
  }) => Timetable(
    id: id ?? this.id,
    date: date.present ? date.value : this.date,
    day: day.present ? day.value : this.day,
    updated: updated.present ? updated.value : this.updated,
    firstFetched: firstFetched.present ? firstFetched.value : this.firstFetched,
    lastFetched: lastFetched.present ? lastFetched.value : this.lastFetched,
    extraInfos: extraInfos.present ? extraInfos.value : this.extraInfos,
  );
  Timetable copyWithCompanion(TimetablesCompanion data) {
    return Timetable(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      day: data.day.present ? data.day.value : this.day,
      updated: data.updated.present ? data.updated.value : this.updated,
      firstFetched: data.firstFetched.present
          ? data.firstFetched.value
          : this.firstFetched,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      extraInfos: data.extraInfos.present
          ? data.extraInfos.value
          : this.extraInfos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Timetable(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('day: $day, ')
          ..write('updated: $updated, ')
          ..write('firstFetched: $firstFetched, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('extraInfos: $extraInfos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    day,
    updated,
    firstFetched,
    lastFetched,
    extraInfos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Timetable &&
          other.id == this.id &&
          other.date == this.date &&
          other.day == this.day &&
          other.updated == this.updated &&
          other.firstFetched == this.firstFetched &&
          other.lastFetched == this.lastFetched &&
          other.extraInfos == this.extraInfos);
}

class TimetablesCompanion extends UpdateCompanion<Timetable> {
  final Value<int> id;
  final Value<DateTime?> date;
  final Value<Weekday?> day;
  final Value<DateTime?> updated;
  final Value<DateTime?> firstFetched;
  final Value<DateTime?> lastFetched;
  final Value<Map<String, String>?> extraInfos;
  const TimetablesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.day = const Value.absent(),
    this.updated = const Value.absent(),
    this.firstFetched = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.extraInfos = const Value.absent(),
  });
  TimetablesCompanion.insert({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.day = const Value.absent(),
    this.updated = const Value.absent(),
    this.firstFetched = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.extraInfos = const Value.absent(),
  });
  static Insertable<Timetable> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? day,
    Expression<DateTime>? updated,
    Expression<DateTime>? firstFetched,
    Expression<DateTime>? lastFetched,
    Expression<String>? extraInfos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (day != null) 'day': day,
      if (updated != null) 'updated': updated,
      if (firstFetched != null) 'first_fetched': firstFetched,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (extraInfos != null) 'extra_infos': extraInfos,
    });
  }

  TimetablesCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? date,
    Value<Weekday?>? day,
    Value<DateTime?>? updated,
    Value<DateTime?>? firstFetched,
    Value<DateTime?>? lastFetched,
    Value<Map<String, String>?>? extraInfos,
  }) {
    return TimetablesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      day: day ?? this.day,
      updated: updated ?? this.updated,
      firstFetched: firstFetched ?? this.firstFetched,
      lastFetched: lastFetched ?? this.lastFetched,
      extraInfos: extraInfos ?? this.extraInfos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(
        $TimetablesTable.$converterdayn.toSql(day.value),
      );
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (firstFetched.present) {
      map['first_fetched'] = Variable<DateTime>(firstFetched.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
    }
    if (extraInfos.present) {
      map['extra_infos'] = Variable<String>(
        $TimetablesTable.$converterextraInfosn.toSql(extraInfos.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetablesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('day: $day, ')
          ..write('updated: $updated, ')
          ..write('firstFetched: $firstFetched, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('extraInfos: $extraInfos')
          ..write(')'))
        .toString();
  }
}

class $ClassEntriesTable extends ClassEntries
    with TableInfo<$ClassEntriesTable, ClassEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timetableIdMeta = const VerificationMeta(
    'timetableId',
  );
  @override
  late final GeneratedColumn<int> timetableId = GeneratedColumn<int>(
    'timetable_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetables (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> classNames =
      GeneratedColumn<String>(
        'class_names',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ClassEntriesTable.$converterclassNames);
  @override
  List<GeneratedColumn> get $columns => [id, timetableId, classNames];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timetable_id')) {
      context.handle(
        _timetableIdMeta,
        timetableId.isAcceptableOrUnknown(
          data['timetable_id']!,
          _timetableIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timetableIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timetable_id'],
      )!,
      classNames: $ClassEntriesTable.$converterclassNames.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}class_names'],
        )!,
      ),
    );
  }

  @override
  $ClassEntriesTable createAlias(String alias) {
    return $ClassEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterclassNames =
      const StringListConverter();
}

class ClassEntry extends DataClass implements Insertable<ClassEntry> {
  final int id;
  final int timetableId;
  final List<String> classNames;
  const ClassEntry({
    required this.id,
    required this.timetableId,
    required this.classNames,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timetable_id'] = Variable<int>(timetableId);
    {
      map['class_names'] = Variable<String>(
        $ClassEntriesTable.$converterclassNames.toSql(classNames),
      );
    }
    return map;
  }

  ClassEntriesCompanion toCompanion(bool nullToAbsent) {
    return ClassEntriesCompanion(
      id: Value(id),
      timetableId: Value(timetableId),
      classNames: Value(classNames),
    );
  }

  factory ClassEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassEntry(
      id: serializer.fromJson<int>(json['id']),
      timetableId: serializer.fromJson<int>(json['timetableId']),
      classNames: serializer.fromJson<List<String>>(json['classNames']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timetableId': serializer.toJson<int>(timetableId),
      'classNames': serializer.toJson<List<String>>(classNames),
    };
  }

  ClassEntry copyWith({int? id, int? timetableId, List<String>? classNames}) =>
      ClassEntry(
        id: id ?? this.id,
        timetableId: timetableId ?? this.timetableId,
        classNames: classNames ?? this.classNames,
      );
  ClassEntry copyWithCompanion(ClassEntriesCompanion data) {
    return ClassEntry(
      id: data.id.present ? data.id.value : this.id,
      timetableId: data.timetableId.present
          ? data.timetableId.value
          : this.timetableId,
      classNames: data.classNames.present
          ? data.classNames.value
          : this.classNames,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassEntry(')
          ..write('id: $id, ')
          ..write('timetableId: $timetableId, ')
          ..write('classNames: $classNames')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timetableId, classNames);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassEntry &&
          other.id == this.id &&
          other.timetableId == this.timetableId &&
          other.classNames == this.classNames);
}

class ClassEntriesCompanion extends UpdateCompanion<ClassEntry> {
  final Value<int> id;
  final Value<int> timetableId;
  final Value<List<String>> classNames;
  const ClassEntriesCompanion({
    this.id = const Value.absent(),
    this.timetableId = const Value.absent(),
    this.classNames = const Value.absent(),
  });
  ClassEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int timetableId,
    required List<String> classNames,
  }) : timetableId = Value(timetableId),
       classNames = Value(classNames);
  static Insertable<ClassEntry> custom({
    Expression<int>? id,
    Expression<int>? timetableId,
    Expression<String>? classNames,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timetableId != null) 'timetable_id': timetableId,
      if (classNames != null) 'class_names': classNames,
    });
  }

  ClassEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? timetableId,
    Value<List<String>>? classNames,
  }) {
    return ClassEntriesCompanion(
      id: id ?? this.id,
      timetableId: timetableId ?? this.timetableId,
      classNames: classNames ?? this.classNames,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timetableId.present) {
      map['timetable_id'] = Variable<int>(timetableId.value);
    }
    if (classNames.present) {
      map['class_names'] = Variable<String>(
        $ClassEntriesTable.$converterclassNames.toSql(classNames.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassEntriesCompanion(')
          ..write('id: $id, ')
          ..write('timetableId: $timetableId, ')
          ..write('classNames: $classNames')
          ..write(')'))
        .toString();
  }
}

class $TimetableEntriesTable extends TimetableEntries
    with TableInfo<$TimetableEntriesTable, TimetableEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classEntryIdMeta = const VerificationMeta(
    'classEntryId',
  );
  @override
  late final GeneratedColumn<int> classEntryId = GeneratedColumn<int>(
    'class_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES class_entries (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LessonRange?, String> lesson =
      GeneratedColumn<String>(
        'lesson',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LessonRange?>($TimetableEntriesTable.$converterlessonn);
  static const VerificationMeta _teacherMeta = const VerificationMeta(
    'teacher',
  );
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
    'teacher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimetableStatusType?, String>
  type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<TimetableStatusType?>($TimetableEntriesTable.$convertertypen);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classEntryId,
    lesson,
    teacher,
    subject,
    room,
    type,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_entry_id')) {
      context.handle(
        _classEntryIdMeta,
        classEntryId.isAcceptableOrUnknown(
          data['class_entry_id']!,
          _classEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classEntryIdMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(
        _teacherMeta,
        teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_entry_id'],
      )!,
      lesson: $TimetableEntriesTable.$converterlessonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}lesson'],
        ),
      ),
      teacher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher'],
      ),
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
      type: $TimetableEntriesTable.$convertertypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        ),
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $TimetableEntriesTable createAlias(String alias) {
    return $TimetableEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<LessonRange, String> $converterlesson =
      const LessonRangeConverter();
  static TypeConverter<LessonRange?, String?> $converterlessonn =
      NullAwareTypeConverter.wrap($converterlesson);
  static TypeConverter<TimetableStatusType, String> $convertertype =
      const TimetableStatusTypeConverter();
  static TypeConverter<TimetableStatusType?, String?> $convertertypen =
      NullAwareTypeConverter.wrap($convertertype);
}

class TimetableEntry extends DataClass implements Insertable<TimetableEntry> {
  final int id;
  final int classEntryId;
  final LessonRange? lesson;
  final String? teacher;
  final String? subject;
  final String? room;
  final TimetableStatusType? type;
  final String? description;
  const TimetableEntry({
    required this.id,
    required this.classEntryId,
    this.lesson,
    this.teacher,
    this.subject,
    this.room,
    this.type,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_entry_id'] = Variable<int>(classEntryId);
    if (!nullToAbsent || lesson != null) {
      map['lesson'] = Variable<String>(
        $TimetableEntriesTable.$converterlessonn.toSql(lesson),
      );
    }
    if (!nullToAbsent || teacher != null) {
      map['teacher'] = Variable<String>(teacher);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(
        $TimetableEntriesTable.$convertertypen.toSql(type),
      );
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  TimetableEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimetableEntriesCompanion(
      id: Value(id),
      classEntryId: Value(classEntryId),
      lesson: lesson == null && nullToAbsent
          ? const Value.absent()
          : Value(lesson),
      teacher: teacher == null && nullToAbsent
          ? const Value.absent()
          : Value(teacher),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory TimetableEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableEntry(
      id: serializer.fromJson<int>(json['id']),
      classEntryId: serializer.fromJson<int>(json['classEntryId']),
      lesson: serializer.fromJson<LessonRange?>(json['lesson']),
      teacher: serializer.fromJson<String?>(json['teacher']),
      subject: serializer.fromJson<String?>(json['subject']),
      room: serializer.fromJson<String?>(json['room']),
      type: serializer.fromJson<TimetableStatusType?>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classEntryId': serializer.toJson<int>(classEntryId),
      'lesson': serializer.toJson<LessonRange?>(lesson),
      'teacher': serializer.toJson<String?>(teacher),
      'subject': serializer.toJson<String?>(subject),
      'room': serializer.toJson<String?>(room),
      'type': serializer.toJson<TimetableStatusType?>(type),
      'description': serializer.toJson<String?>(description),
    };
  }

  TimetableEntry copyWith({
    int? id,
    int? classEntryId,
    Value<LessonRange?> lesson = const Value.absent(),
    Value<String?> teacher = const Value.absent(),
    Value<String?> subject = const Value.absent(),
    Value<String?> room = const Value.absent(),
    Value<TimetableStatusType?> type = const Value.absent(),
    Value<String?> description = const Value.absent(),
  }) => TimetableEntry(
    id: id ?? this.id,
    classEntryId: classEntryId ?? this.classEntryId,
    lesson: lesson.present ? lesson.value : this.lesson,
    teacher: teacher.present ? teacher.value : this.teacher,
    subject: subject.present ? subject.value : this.subject,
    room: room.present ? room.value : this.room,
    type: type.present ? type.value : this.type,
    description: description.present ? description.value : this.description,
  );
  TimetableEntry copyWithCompanion(TimetableEntriesCompanion data) {
    return TimetableEntry(
      id: data.id.present ? data.id.value : this.id,
      classEntryId: data.classEntryId.present
          ? data.classEntryId.value
          : this.classEntryId,
      lesson: data.lesson.present ? data.lesson.value : this.lesson,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      subject: data.subject.present ? data.subject.value : this.subject,
      room: data.room.present ? data.room.value : this.room,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntry(')
          ..write('id: $id, ')
          ..write('classEntryId: $classEntryId, ')
          ..write('lesson: $lesson, ')
          ..write('teacher: $teacher, ')
          ..write('subject: $subject, ')
          ..write('room: $room, ')
          ..write('type: $type, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    classEntryId,
    lesson,
    teacher,
    subject,
    room,
    type,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableEntry &&
          other.id == this.id &&
          other.classEntryId == this.classEntryId &&
          other.lesson == this.lesson &&
          other.teacher == this.teacher &&
          other.subject == this.subject &&
          other.room == this.room &&
          other.type == this.type &&
          other.description == this.description);
}

class TimetableEntriesCompanion extends UpdateCompanion<TimetableEntry> {
  final Value<int> id;
  final Value<int> classEntryId;
  final Value<LessonRange?> lesson;
  final Value<String?> teacher;
  final Value<String?> subject;
  final Value<String?> room;
  final Value<TimetableStatusType?> type;
  final Value<String?> description;
  const TimetableEntriesCompanion({
    this.id = const Value.absent(),
    this.classEntryId = const Value.absent(),
    this.lesson = const Value.absent(),
    this.teacher = const Value.absent(),
    this.subject = const Value.absent(),
    this.room = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
  });
  TimetableEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int classEntryId,
    this.lesson = const Value.absent(),
    this.teacher = const Value.absent(),
    this.subject = const Value.absent(),
    this.room = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
  }) : classEntryId = Value(classEntryId);
  static Insertable<TimetableEntry> custom({
    Expression<int>? id,
    Expression<int>? classEntryId,
    Expression<String>? lesson,
    Expression<String>? teacher,
    Expression<String>? subject,
    Expression<String>? room,
    Expression<String>? type,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classEntryId != null) 'class_entry_id': classEntryId,
      if (lesson != null) 'lesson': lesson,
      if (teacher != null) 'teacher': teacher,
      if (subject != null) 'subject': subject,
      if (room != null) 'room': room,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
    });
  }

  TimetableEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? classEntryId,
    Value<LessonRange?>? lesson,
    Value<String?>? teacher,
    Value<String?>? subject,
    Value<String?>? room,
    Value<TimetableStatusType?>? type,
    Value<String?>? description,
  }) {
    return TimetableEntriesCompanion(
      id: id ?? this.id,
      classEntryId: classEntryId ?? this.classEntryId,
      lesson: lesson ?? this.lesson,
      teacher: teacher ?? this.teacher,
      subject: subject ?? this.subject,
      room: room ?? this.room,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classEntryId.present) {
      map['class_entry_id'] = Variable<int>(classEntryId.value);
    }
    if (lesson.present) {
      map['lesson'] = Variable<String>(
        $TimetableEntriesTable.$converterlessonn.toSql(lesson.value),
      );
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TimetableEntriesTable.$convertertypen.toSql(type.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntriesCompanion(')
          ..write('id: $id, ')
          ..write('classEntryId: $classEntryId, ')
          ..write('lesson: $lesson, ')
          ..write('teacher: $teacher, ')
          ..write('subject: $subject, ')
          ..write('room: $room, ')
          ..write('type: $type, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TimetablesTable timetables = $TimetablesTable(this);
  late final $ClassEntriesTable classEntries = $ClassEntriesTable(this);
  late final $TimetableEntriesTable timetableEntries = $TimetableEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    timetables,
    classEntries,
    timetableEntries,
  ];
}

typedef $$TimetablesTableCreateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      Value<DateTime?> date,
      Value<Weekday?> day,
      Value<DateTime?> updated,
      Value<DateTime?> firstFetched,
      Value<DateTime?> lastFetched,
      Value<Map<String, String>?> extraInfos,
    });
typedef $$TimetablesTableUpdateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      Value<DateTime?> date,
      Value<Weekday?> day,
      Value<DateTime?> updated,
      Value<DateTime?> firstFetched,
      Value<DateTime?> lastFetched,
      Value<Map<String, String>?> extraInfos,
    });

final class $$TimetablesTableReferences
    extends BaseReferences<_$AppDatabase, $TimetablesTable, Timetable> {
  $$TimetablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClassEntriesTable, List<ClassEntry>>
  _classEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.classEntries,
    aliasName: 'timetables__id__class_entries__timetable_id',
  );

  $$ClassEntriesTableProcessedTableManager get classEntriesRefs {
    final manager = $$ClassEntriesTableTableManager(
      $_db,
      $_db.classEntries,
    ).filter((f) => f.timetableId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_classEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimetablesTableFilterComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weekday?, Weekday, String> get day =>
      $composableBuilder(
        column: $table.day,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstFetched => $composableBuilder(
    column: $table.firstFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>?,
    Map<String, String>,
    String
  >
  get extraInfos => $composableBuilder(
    column: $table.extraInfos,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> classEntriesRefs(
    Expression<bool> Function($$ClassEntriesTableFilterComposer f) f,
  ) {
    final $$ClassEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classEntries,
      getReferencedColumn: (t) => t.timetableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassEntriesTableFilterComposer(
            $db: $db,
            $table: $db.classEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimetablesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstFetched => $composableBuilder(
    column: $table.firstFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraInfos => $composableBuilder(
    column: $table.extraInfos,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Weekday?, String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<DateTime> get firstFetched => $composableBuilder(
    column: $table.firstFetched,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>?, String>
  get extraInfos => $composableBuilder(
    column: $table.extraInfos,
    builder: (column) => column,
  );

  Expression<T> classEntriesRefs<T extends Object>(
    Expression<T> Function($$ClassEntriesTableAnnotationComposer a) f,
  ) {
    final $$ClassEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classEntries,
      getReferencedColumn: (t) => t.timetableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.classEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimetablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetablesTable,
          Timetable,
          $$TimetablesTableFilterComposer,
          $$TimetablesTableOrderingComposer,
          $$TimetablesTableAnnotationComposer,
          $$TimetablesTableCreateCompanionBuilder,
          $$TimetablesTableUpdateCompanionBuilder,
          (Timetable, $$TimetablesTableReferences),
          Timetable,
          PrefetchHooks Function({bool classEntriesRefs})
        > {
  $$TimetablesTableTableManager(_$AppDatabase db, $TimetablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<Weekday?> day = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<DateTime?> firstFetched = const Value.absent(),
                Value<DateTime?> lastFetched = const Value.absent(),
                Value<Map<String, String>?> extraInfos = const Value.absent(),
              }) => TimetablesCompanion(
                id: id,
                date: date,
                day: day,
                updated: updated,
                firstFetched: firstFetched,
                lastFetched: lastFetched,
                extraInfos: extraInfos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<Weekday?> day = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<DateTime?> firstFetched = const Value.absent(),
                Value<DateTime?> lastFetched = const Value.absent(),
                Value<Map<String, String>?> extraInfos = const Value.absent(),
              }) => TimetablesCompanion.insert(
                id: id,
                date: date,
                day: day,
                updated: updated,
                firstFetched: firstFetched,
                lastFetched: lastFetched,
                extraInfos: extraInfos,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetablesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (classEntriesRefs) db.classEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (classEntriesRefs)
                    await $_getPrefetchedData<
                      Timetable,
                      $TimetablesTable,
                      ClassEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TimetablesTableReferences
                          ._classEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimetablesTableReferences(
                            db,
                            table,
                            p0,
                          ).classEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.timetableId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimetablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetablesTable,
      Timetable,
      $$TimetablesTableFilterComposer,
      $$TimetablesTableOrderingComposer,
      $$TimetablesTableAnnotationComposer,
      $$TimetablesTableCreateCompanionBuilder,
      $$TimetablesTableUpdateCompanionBuilder,
      (Timetable, $$TimetablesTableReferences),
      Timetable,
      PrefetchHooks Function({bool classEntriesRefs})
    >;
typedef $$ClassEntriesTableCreateCompanionBuilder =
    ClassEntriesCompanion Function({
      Value<int> id,
      required int timetableId,
      required List<String> classNames,
    });
typedef $$ClassEntriesTableUpdateCompanionBuilder =
    ClassEntriesCompanion Function({
      Value<int> id,
      Value<int> timetableId,
      Value<List<String>> classNames,
    });

final class $$ClassEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ClassEntriesTable, ClassEntry> {
  $$ClassEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimetablesTable _timetableIdTable(_$AppDatabase db) =>
      db.timetables.createAlias('class_entries__timetable_id__timetables__id');

  $$TimetablesTableProcessedTableManager get timetableId {
    final $_column = $_itemColumn<int>('timetable_id')!;

    final manager = $$TimetablesTableTableManager(
      $_db,
      $_db.timetables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_timetableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TimetableEntriesTable, List<TimetableEntry>>
  _timetableEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetableEntries,
    aliasName: 'class_entries__id__timetable_entries__class_entry_id',
  );

  $$TimetableEntriesTableProcessedTableManager get timetableEntriesRefs {
    final manager = $$TimetableEntriesTableTableManager(
      $_db,
      $_db.timetableEntries,
    ).filter((f) => f.classEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timetableEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClassEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassEntriesTable> {
  $$ClassEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get classNames => $composableBuilder(
    column: $table.classNames,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$TimetablesTableFilterComposer get timetableId {
    final $$TimetablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.timetables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablesTableFilterComposer(
            $db: $db,
            $table: $db.timetables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> timetableEntriesRefs(
    Expression<bool> Function($$TimetableEntriesTableFilterComposer f) f,
  ) {
    final $$TimetableEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.classEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClassEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassEntriesTable> {
  $$ClassEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classNames => $composableBuilder(
    column: $table.classNames,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimetablesTableOrderingComposer get timetableId {
    final $$TimetablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.timetables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablesTableOrderingComposer(
            $db: $db,
            $table: $db.timetables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassEntriesTable> {
  $$ClassEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get classNames =>
      $composableBuilder(
        column: $table.classNames,
        builder: (column) => column,
      );

  $$TimetablesTableAnnotationComposer get timetableId {
    final $$TimetablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.timetables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> timetableEntriesRefs<T extends Object>(
    Expression<T> Function($$TimetableEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimetableEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.classEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClassEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassEntriesTable,
          ClassEntry,
          $$ClassEntriesTableFilterComposer,
          $$ClassEntriesTableOrderingComposer,
          $$ClassEntriesTableAnnotationComposer,
          $$ClassEntriesTableCreateCompanionBuilder,
          $$ClassEntriesTableUpdateCompanionBuilder,
          (ClassEntry, $$ClassEntriesTableReferences),
          ClassEntry,
          PrefetchHooks Function({bool timetableId, bool timetableEntriesRefs})
        > {
  $$ClassEntriesTableTableManager(_$AppDatabase db, $ClassEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timetableId = const Value.absent(),
                Value<List<String>> classNames = const Value.absent(),
              }) => ClassEntriesCompanion(
                id: id,
                timetableId: timetableId,
                classNames: classNames,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timetableId,
                required List<String> classNames,
              }) => ClassEntriesCompanion.insert(
                id: id,
                timetableId: timetableId,
                classNames: classNames,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClassEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({timetableId = false, timetableEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (timetableEntriesRefs) db.timetableEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (timetableId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.timetableId,
                                    referencedTable:
                                        $$ClassEntriesTableReferences
                                            ._timetableIdTable(db),
                                    referencedColumn:
                                        $$ClassEntriesTableReferences
                                            ._timetableIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (timetableEntriesRefs)
                        await $_getPrefetchedData<
                          ClassEntry,
                          $ClassEntriesTable,
                          TimetableEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ClassEntriesTableReferences
                              ._timetableEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).timetableEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClassEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassEntriesTable,
      ClassEntry,
      $$ClassEntriesTableFilterComposer,
      $$ClassEntriesTableOrderingComposer,
      $$ClassEntriesTableAnnotationComposer,
      $$ClassEntriesTableCreateCompanionBuilder,
      $$ClassEntriesTableUpdateCompanionBuilder,
      (ClassEntry, $$ClassEntriesTableReferences),
      ClassEntry,
      PrefetchHooks Function({bool timetableId, bool timetableEntriesRefs})
    >;
typedef $$TimetableEntriesTableCreateCompanionBuilder =
    TimetableEntriesCompanion Function({
      Value<int> id,
      required int classEntryId,
      Value<LessonRange?> lesson,
      Value<String?> teacher,
      Value<String?> subject,
      Value<String?> room,
      Value<TimetableStatusType?> type,
      Value<String?> description,
    });
typedef $$TimetableEntriesTableUpdateCompanionBuilder =
    TimetableEntriesCompanion Function({
      Value<int> id,
      Value<int> classEntryId,
      Value<LessonRange?> lesson,
      Value<String?> teacher,
      Value<String?> subject,
      Value<String?> room,
      Value<TimetableStatusType?> type,
      Value<String?> description,
    });

final class $$TimetableEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TimetableEntriesTable, TimetableEntry> {
  $$TimetableEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClassEntriesTable _classEntryIdTable(_$AppDatabase db) => db
      .classEntries
      .createAlias('timetable_entries__class_entry_id__class_entries__id');

  $$ClassEntriesTableProcessedTableManager get classEntryId {
    final $_column = $_itemColumn<int>('class_entry_id')!;

    final manager = $$ClassEntriesTableTableManager(
      $_db,
      $_db.classEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimetableEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LessonRange?, LessonRange, String>
  get lesson => $composableBuilder(
    column: $table.lesson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TimetableStatusType?,
    TimetableStatusType,
    String
  >
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassEntriesTableFilterComposer get classEntryId {
    final $$ClassEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classEntryId,
      referencedTable: $db.classEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassEntriesTableFilterComposer(
            $db: $db,
            $table: $db.classEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lesson => $composableBuilder(
    column: $table.lesson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassEntriesTableOrderingComposer get classEntryId {
    final $$ClassEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classEntryId,
      referencedTable: $db.classEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.classEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LessonRange?, String> get lesson =>
      $composableBuilder(column: $table.lesson, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimetableStatusType?, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$ClassEntriesTableAnnotationComposer get classEntryId {
    final $$ClassEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classEntryId,
      referencedTable: $db.classEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.classEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableEntriesTable,
          TimetableEntry,
          $$TimetableEntriesTableFilterComposer,
          $$TimetableEntriesTableOrderingComposer,
          $$TimetableEntriesTableAnnotationComposer,
          $$TimetableEntriesTableCreateCompanionBuilder,
          $$TimetableEntriesTableUpdateCompanionBuilder,
          (TimetableEntry, $$TimetableEntriesTableReferences),
          TimetableEntry,
          PrefetchHooks Function({bool classEntryId})
        > {
  $$TimetableEntriesTableTableManager(
    _$AppDatabase db,
    $TimetableEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classEntryId = const Value.absent(),
                Value<LessonRange?> lesson = const Value.absent(),
                Value<String?> teacher = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<TimetableStatusType?> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => TimetableEntriesCompanion(
                id: id,
                classEntryId: classEntryId,
                lesson: lesson,
                teacher: teacher,
                subject: subject,
                room: room,
                type: type,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classEntryId,
                Value<LessonRange?> lesson = const Value.absent(),
                Value<String?> teacher = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<TimetableStatusType?> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => TimetableEntriesCompanion.insert(
                id: id,
                classEntryId: classEntryId,
                lesson: lesson,
                teacher: teacher,
                subject: subject,
                room: room,
                type: type,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetableEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classEntryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (classEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.classEntryId,
                                referencedTable:
                                    $$TimetableEntriesTableReferences
                                        ._classEntryIdTable(db),
                                referencedColumn:
                                    $$TimetableEntriesTableReferences
                                        ._classEntryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimetableEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableEntriesTable,
      TimetableEntry,
      $$TimetableEntriesTableFilterComposer,
      $$TimetableEntriesTableOrderingComposer,
      $$TimetableEntriesTableAnnotationComposer,
      $$TimetableEntriesTableCreateCompanionBuilder,
      $$TimetableEntriesTableUpdateCompanionBuilder,
      (TimetableEntry, $$TimetableEntriesTableReferences),
      TimetableEntry,
      PrefetchHooks Function({bool classEntryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TimetablesTableTableManager get timetables =>
      $$TimetablesTableTableManager(_db, _db.timetables);
  $$ClassEntriesTableTableManager get classEntries =>
      $$ClassEntriesTableTableManager(_db, _db.classEntries);
  $$TimetableEntriesTableTableManager get timetableEntries =>
      $$TimetableEntriesTableTableManager(_db, _db.timetableEntries);
}
