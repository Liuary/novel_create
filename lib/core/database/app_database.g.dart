// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, DbBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, path, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class DbBook extends DataClass implements Insertable<DbBook> {
  final String id;
  final String name;
  final String? path;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbBook({
    required this.id,
    required this.name,
    this.path,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      name: Value(name),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbBook(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String?>(json['path']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String?>(path),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbBook copyWith({
    String? id,
    String? name,
    Value<String?> path = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbBook(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path.present ? path.value : this.path,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbBook copyWithCompanion(BooksCompanion data) {
    return DbBook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbBook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, path, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbBook &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<DbBook> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> path;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String name,
    this.path = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbBook> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? path,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VolumesTable extends Volumes with TableInfo<$VolumesTable, DbVolume> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VolumesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'volumes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbVolume> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbVolume map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbVolume(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VolumesTable createAlias(String alias) {
    return $VolumesTable(attachedDatabase, alias);
  }
}

class DbVolume extends DataClass implements Insertable<DbVolume> {
  final String id;
  final String bookId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbVolume({
    required this.id,
    required this.bookId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VolumesCompanion toCompanion(bool nullToAbsent) {
    return VolumesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbVolume.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbVolume(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbVolume copyWith({
    String? id,
    String? bookId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbVolume(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbVolume copyWithCompanion(VolumesCompanion data) {
    return DbVolume(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbVolume(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, name, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbVolume &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VolumesCompanion extends UpdateCompanion<DbVolume> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VolumesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VolumesCompanion.insert({
    required String id,
    required String bookId,
    required String name,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       name = Value(name);
  static Insertable<DbVolume> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VolumesCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VolumesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VolumesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, DbChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeIdMeta = const VerificationMeta(
    'volumeId',
  );
  @override
  late final GeneratedColumn<String> volumeId = GeneratedColumn<String>(
    'volume_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    volumeId,
    name,
    filePath,
    sortOrder,
    summary,
    status,
    wordCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('volume_id')) {
      context.handle(
        _volumeIdMeta,
        volumeId.isAcceptableOrUnknown(data['volume_id']!, _volumeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbChapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      volumeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class DbChapter extends DataClass implements Insertable<DbChapter> {
  final String id;
  final String volumeId;
  final String name;
  final String? filePath;
  final int sortOrder;
  final String summary;
  final String status;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbChapter({
    required this.id,
    required this.volumeId,
    required this.name,
    this.filePath,
    required this.sortOrder,
    required this.summary,
    required this.status,
    required this.wordCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['volume_id'] = Variable<String>(volumeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['summary'] = Variable<String>(summary);
    map['status'] = Variable<String>(status);
    map['word_count'] = Variable<int>(wordCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      volumeId: Value(volumeId),
      name: Value(name),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      sortOrder: Value(sortOrder),
      summary: Value(summary),
      status: Value(status),
      wordCount: Value(wordCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbChapter(
      id: serializer.fromJson<String>(json['id']),
      volumeId: serializer.fromJson<String>(json['volumeId']),
      name: serializer.fromJson<String>(json['name']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      summary: serializer.fromJson<String>(json['summary']),
      status: serializer.fromJson<String>(json['status']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'volumeId': serializer.toJson<String>(volumeId),
      'name': serializer.toJson<String>(name),
      'filePath': serializer.toJson<String?>(filePath),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'summary': serializer.toJson<String>(summary),
      'status': serializer.toJson<String>(status),
      'wordCount': serializer.toJson<int>(wordCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbChapter copyWith({
    String? id,
    String? volumeId,
    String? name,
    Value<String?> filePath = const Value.absent(),
    int? sortOrder,
    String? summary,
    String? status,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbChapter(
    id: id ?? this.id,
    volumeId: volumeId ?? this.volumeId,
    name: name ?? this.name,
    filePath: filePath.present ? filePath.value : this.filePath,
    sortOrder: sortOrder ?? this.sortOrder,
    summary: summary ?? this.summary,
    status: status ?? this.status,
    wordCount: wordCount ?? this.wordCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbChapter copyWithCompanion(ChaptersCompanion data) {
    return DbChapter(
      id: data.id.present ? data.id.value : this.id,
      volumeId: data.volumeId.present ? data.volumeId.value : this.volumeId,
      name: data.name.present ? data.name.value : this.name,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbChapter(')
          ..write('id: $id, ')
          ..write('volumeId: $volumeId, ')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('wordCount: $wordCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    volumeId,
    name,
    filePath,
    sortOrder,
    summary,
    status,
    wordCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbChapter &&
          other.id == this.id &&
          other.volumeId == this.volumeId &&
          other.name == this.name &&
          other.filePath == this.filePath &&
          other.sortOrder == this.sortOrder &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.wordCount == this.wordCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChaptersCompanion extends UpdateCompanion<DbChapter> {
  final Value<String> id;
  final Value<String> volumeId;
  final Value<String> name;
  final Value<String?> filePath;
  final Value<int> sortOrder;
  final Value<String> summary;
  final Value<String> status;
  final Value<int> wordCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.volumeId = const Value.absent(),
    this.name = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String volumeId,
    required String name,
    this.filePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       volumeId = Value(volumeId),
       name = Value(name);
  static Insertable<DbChapter> custom({
    Expression<String>? id,
    Expression<String>? volumeId,
    Expression<String>? name,
    Expression<String>? filePath,
    Expression<int>? sortOrder,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<int>? wordCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (volumeId != null) 'volume_id': volumeId,
      if (name != null) 'name': name,
      if (filePath != null) 'file_path': filePath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (wordCount != null) 'word_count': wordCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? volumeId,
    Value<String>? name,
    Value<String?>? filePath,
    Value<int>? sortOrder,
    Value<String>? summary,
    Value<String>? status,
    Value<int>? wordCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      volumeId: volumeId ?? this.volumeId,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      sortOrder: sortOrder ?? this.sortOrder,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (volumeId.present) {
      map['volume_id'] = Variable<String>(volumeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('volumeId: $volumeId, ')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('wordCount: $wordCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityLinksTable extends EntityLinks
    with TableInfo<$EntityLinksTable, DbEntityLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityLinksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fromTypeMeta = const VerificationMeta(
    'fromType',
  );
  @override
  late final GeneratedColumn<String> fromType = GeneratedColumn<String>(
    'from_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<String> fromId = GeneratedColumn<String>(
    'from_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toTypeMeta = const VerificationMeta('toType');
  @override
  late final GeneratedColumn<String> toType = GeneratedColumn<String>(
    'to_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toIdMeta = const VerificationMeta('toId');
  @override
  late final GeneratedColumn<String> toId = GeneratedColumn<String>(
    'to_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkTypeMeta = const VerificationMeta(
    'linkType',
  );
  @override
  late final GeneratedColumn<String> linkType = GeneratedColumn<String>(
    'link_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromType,
    fromId,
    toType,
    toId,
    linkType,
    metadata,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbEntityLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('from_type')) {
      context.handle(
        _fromTypeMeta,
        fromType.isAcceptableOrUnknown(data['from_type']!, _fromTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fromTypeMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('to_type')) {
      context.handle(
        _toTypeMeta,
        toType.isAcceptableOrUnknown(data['to_type']!, _toTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_toTypeMeta);
    }
    if (data.containsKey('to_id')) {
      context.handle(
        _toIdMeta,
        toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toIdMeta);
    }
    if (data.containsKey('link_type')) {
      context.handle(
        _linkTypeMeta,
        linkType.isAcceptableOrUnknown(data['link_type']!, _linkTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_linkTypeMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbEntityLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbEntityLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fromType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_type'],
      )!,
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_id'],
      )!,
      toType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_type'],
      )!,
      toId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_id'],
      )!,
      linkType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_type'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EntityLinksTable createAlias(String alias) {
    return $EntityLinksTable(attachedDatabase, alias);
  }
}

class DbEntityLink extends DataClass implements Insertable<DbEntityLink> {
  final int id;
  final String fromType;
  final String fromId;
  final String toType;
  final String toId;
  final String linkType;
  final String metadata;
  final DateTime createdAt;
  const DbEntityLink({
    required this.id,
    required this.fromType,
    required this.fromId,
    required this.toType,
    required this.toId,
    required this.linkType,
    required this.metadata,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['from_type'] = Variable<String>(fromType);
    map['from_id'] = Variable<String>(fromId);
    map['to_type'] = Variable<String>(toType);
    map['to_id'] = Variable<String>(toId);
    map['link_type'] = Variable<String>(linkType);
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EntityLinksCompanion toCompanion(bool nullToAbsent) {
    return EntityLinksCompanion(
      id: Value(id),
      fromType: Value(fromType),
      fromId: Value(fromId),
      toType: Value(toType),
      toId: Value(toId),
      linkType: Value(linkType),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory DbEntityLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbEntityLink(
      id: serializer.fromJson<int>(json['id']),
      fromType: serializer.fromJson<String>(json['fromType']),
      fromId: serializer.fromJson<String>(json['fromId']),
      toType: serializer.fromJson<String>(json['toType']),
      toId: serializer.fromJson<String>(json['toId']),
      linkType: serializer.fromJson<String>(json['linkType']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fromType': serializer.toJson<String>(fromType),
      'fromId': serializer.toJson<String>(fromId),
      'toType': serializer.toJson<String>(toType),
      'toId': serializer.toJson<String>(toId),
      'linkType': serializer.toJson<String>(linkType),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbEntityLink copyWith({
    int? id,
    String? fromType,
    String? fromId,
    String? toType,
    String? toId,
    String? linkType,
    String? metadata,
    DateTime? createdAt,
  }) => DbEntityLink(
    id: id ?? this.id,
    fromType: fromType ?? this.fromType,
    fromId: fromId ?? this.fromId,
    toType: toType ?? this.toType,
    toId: toId ?? this.toId,
    linkType: linkType ?? this.linkType,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
  );
  DbEntityLink copyWithCompanion(EntityLinksCompanion data) {
    return DbEntityLink(
      id: data.id.present ? data.id.value : this.id,
      fromType: data.fromType.present ? data.fromType.value : this.fromType,
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      toType: data.toType.present ? data.toType.value : this.toType,
      toId: data.toId.present ? data.toId.value : this.toId,
      linkType: data.linkType.present ? data.linkType.value : this.linkType,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbEntityLink(')
          ..write('id: $id, ')
          ..write('fromType: $fromType, ')
          ..write('fromId: $fromId, ')
          ..write('toType: $toType, ')
          ..write('toId: $toId, ')
          ..write('linkType: $linkType, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromType,
    fromId,
    toType,
    toId,
    linkType,
    metadata,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbEntityLink &&
          other.id == this.id &&
          other.fromType == this.fromType &&
          other.fromId == this.fromId &&
          other.toType == this.toType &&
          other.toId == this.toId &&
          other.linkType == this.linkType &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class EntityLinksCompanion extends UpdateCompanion<DbEntityLink> {
  final Value<int> id;
  final Value<String> fromType;
  final Value<String> fromId;
  final Value<String> toType;
  final Value<String> toId;
  final Value<String> linkType;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  const EntityLinksCompanion({
    this.id = const Value.absent(),
    this.fromType = const Value.absent(),
    this.fromId = const Value.absent(),
    this.toType = const Value.absent(),
    this.toId = const Value.absent(),
    this.linkType = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EntityLinksCompanion.insert({
    this.id = const Value.absent(),
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
    required String linkType,
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : fromType = Value(fromType),
       fromId = Value(fromId),
       toType = Value(toType),
       toId = Value(toId),
       linkType = Value(linkType);
  static Insertable<DbEntityLink> custom({
    Expression<int>? id,
    Expression<String>? fromType,
    Expression<String>? fromId,
    Expression<String>? toType,
    Expression<String>? toId,
    Expression<String>? linkType,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromType != null) 'from_type': fromType,
      if (fromId != null) 'from_id': fromId,
      if (toType != null) 'to_type': toType,
      if (toId != null) 'to_id': toId,
      if (linkType != null) 'link_type': linkType,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EntityLinksCompanion copyWith({
    Value<int>? id,
    Value<String>? fromType,
    Value<String>? fromId,
    Value<String>? toType,
    Value<String>? toId,
    Value<String>? linkType,
    Value<String>? metadata,
    Value<DateTime>? createdAt,
  }) {
    return EntityLinksCompanion(
      id: id ?? this.id,
      fromType: fromType ?? this.fromType,
      fromId: fromId ?? this.fromId,
      toType: toType ?? this.toType,
      toId: toId ?? this.toId,
      linkType: linkType ?? this.linkType,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fromType.present) {
      map['from_type'] = Variable<String>(fromType.value);
    }
    if (fromId.present) {
      map['from_id'] = Variable<String>(fromId.value);
    }
    if (toType.present) {
      map['to_type'] = Variable<String>(toType.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<String>(toId.value);
    }
    if (linkType.present) {
      map['link_type'] = Variable<String>(linkType.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityLinksCompanion(')
          ..write('id: $id, ')
          ..write('fromType: $fromType, ')
          ..write('fromId: $fromId, ')
          ..write('toType: $toType, ')
          ..write('toId: $toId, ')
          ..write('linkType: $linkType, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StyleProfilesTable extends StyleProfiles
    with TableInfo<$StyleProfilesTable, DbStyleProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StyleProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemPromptTemplateMeta =
      const VerificationMeta('systemPromptTemplate');
  @override
  late final GeneratedColumn<String> systemPromptTemplate =
      GeneratedColumn<String>(
        'system_prompt_template',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _exampleTextMeta = const VerificationMeta(
    'exampleText',
  );
  @override
  late final GeneratedColumn<String> exampleText = GeneratedColumn<String>(
    'example_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parametersJsonMeta = const VerificationMeta(
    'parametersJson',
  );
  @override
  late final GeneratedColumn<String> parametersJson = GeneratedColumn<String>(
    'parameters_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    systemPromptTemplate,
    exampleText,
    parametersJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'style_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbStyleProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('system_prompt_template')) {
      context.handle(
        _systemPromptTemplateMeta,
        systemPromptTemplate.isAcceptableOrUnknown(
          data['system_prompt_template']!,
          _systemPromptTemplateMeta,
        ),
      );
    }
    if (data.containsKey('example_text')) {
      context.handle(
        _exampleTextMeta,
        exampleText.isAcceptableOrUnknown(
          data['example_text']!,
          _exampleTextMeta,
        ),
      );
    }
    if (data.containsKey('parameters_json')) {
      context.handle(
        _parametersJsonMeta,
        parametersJson.isAcceptableOrUnknown(
          data['parameters_json']!,
          _parametersJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbStyleProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbStyleProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      systemPromptTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt_template'],
      )!,
      exampleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_text'],
      )!,
      parametersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameters_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StyleProfilesTable createAlias(String alias) {
    return $StyleProfilesTable(attachedDatabase, alias);
  }
}

class DbStyleProfile extends DataClass implements Insertable<DbStyleProfile> {
  final String id;
  final String name;
  final String systemPromptTemplate;
  final String exampleText;
  final String parametersJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbStyleProfile({
    required this.id,
    required this.name,
    required this.systemPromptTemplate,
    required this.exampleText,
    required this.parametersJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['system_prompt_template'] = Variable<String>(systemPromptTemplate);
    map['example_text'] = Variable<String>(exampleText);
    map['parameters_json'] = Variable<String>(parametersJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StyleProfilesCompanion toCompanion(bool nullToAbsent) {
    return StyleProfilesCompanion(
      id: Value(id),
      name: Value(name),
      systemPromptTemplate: Value(systemPromptTemplate),
      exampleText: Value(exampleText),
      parametersJson: Value(parametersJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbStyleProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbStyleProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      systemPromptTemplate: serializer.fromJson<String>(
        json['systemPromptTemplate'],
      ),
      exampleText: serializer.fromJson<String>(json['exampleText']),
      parametersJson: serializer.fromJson<String>(json['parametersJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'systemPromptTemplate': serializer.toJson<String>(systemPromptTemplate),
      'exampleText': serializer.toJson<String>(exampleText),
      'parametersJson': serializer.toJson<String>(parametersJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbStyleProfile copyWith({
    String? id,
    String? name,
    String? systemPromptTemplate,
    String? exampleText,
    String? parametersJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbStyleProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    systemPromptTemplate: systemPromptTemplate ?? this.systemPromptTemplate,
    exampleText: exampleText ?? this.exampleText,
    parametersJson: parametersJson ?? this.parametersJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbStyleProfile copyWithCompanion(StyleProfilesCompanion data) {
    return DbStyleProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      systemPromptTemplate: data.systemPromptTemplate.present
          ? data.systemPromptTemplate.value
          : this.systemPromptTemplate,
      exampleText: data.exampleText.present
          ? data.exampleText.value
          : this.exampleText,
      parametersJson: data.parametersJson.present
          ? data.parametersJson.value
          : this.parametersJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbStyleProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('systemPromptTemplate: $systemPromptTemplate, ')
          ..write('exampleText: $exampleText, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    systemPromptTemplate,
    exampleText,
    parametersJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbStyleProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.systemPromptTemplate == this.systemPromptTemplate &&
          other.exampleText == this.exampleText &&
          other.parametersJson == this.parametersJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StyleProfilesCompanion extends UpdateCompanion<DbStyleProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> systemPromptTemplate;
  final Value<String> exampleText;
  final Value<String> parametersJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StyleProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.systemPromptTemplate = const Value.absent(),
    this.exampleText = const Value.absent(),
    this.parametersJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StyleProfilesCompanion.insert({
    required String id,
    required String name,
    this.systemPromptTemplate = const Value.absent(),
    this.exampleText = const Value.absent(),
    this.parametersJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbStyleProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? systemPromptTemplate,
    Expression<String>? exampleText,
    Expression<String>? parametersJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (systemPromptTemplate != null)
        'system_prompt_template': systemPromptTemplate,
      if (exampleText != null) 'example_text': exampleText,
      if (parametersJson != null) 'parameters_json': parametersJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StyleProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? systemPromptTemplate,
    Value<String>? exampleText,
    Value<String>? parametersJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StyleProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      systemPromptTemplate: systemPromptTemplate ?? this.systemPromptTemplate,
      exampleText: exampleText ?? this.exampleText,
      parametersJson: parametersJson ?? this.parametersJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (systemPromptTemplate.present) {
      map['system_prompt_template'] = Variable<String>(
        systemPromptTemplate.value,
      );
    }
    if (exampleText.present) {
      map['example_text'] = Variable<String>(exampleText.value);
    }
    if (parametersJson.present) {
      map['parameters_json'] = Variable<String>(parametersJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StyleProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('systemPromptTemplate: $systemPromptTemplate, ')
          ..write('exampleText: $exampleText, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryTagsTable extends CategoryTags
    with TableInfo<$CategoryTagsTable, DbCategoryTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    parentId,
    moduleId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCategoryTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCategoryTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCategoryTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoryTagsTable createAlias(String alias) {
    return $CategoryTagsTable(attachedDatabase, alias);
  }
}

class DbCategoryTag extends DataClass implements Insertable<DbCategoryTag> {
  final String id;
  final String name;
  final String? parentId;
  final String moduleId;
  final DateTime createdAt;
  const DbCategoryTag({
    required this.id,
    required this.name,
    this.parentId,
    required this.moduleId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['module_id'] = Variable<String>(moduleId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoryTagsCompanion toCompanion(bool nullToAbsent) {
    return CategoryTagsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      moduleId: Value(moduleId),
      createdAt: Value(createdAt),
    );
  }

  factory DbCategoryTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCategoryTag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'moduleId': serializer.toJson<String>(moduleId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbCategoryTag copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    String? moduleId,
    DateTime? createdAt,
  }) => DbCategoryTag(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    moduleId: moduleId ?? this.moduleId,
    createdAt: createdAt ?? this.createdAt,
  );
  DbCategoryTag copyWithCompanion(CategoryTagsCompanion data) {
    return DbCategoryTag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCategoryTag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('moduleId: $moduleId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, moduleId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCategoryTag &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.moduleId == this.moduleId &&
          other.createdAt == this.createdAt);
}

class CategoryTagsCompanion extends UpdateCompanion<DbCategoryTag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<String> moduleId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoryTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryTagsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbCategoryTag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? moduleId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (moduleId != null) 'module_id': moduleId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<String>? moduleId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoryTagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      moduleId: moduleId ?? this.moduleId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('moduleId: $moduleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutlineNodesTable extends OutlineNodes
    with TableInfo<$OutlineNodesTable, DbOutlineNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutlineNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expectedWordCountMeta = const VerificationMeta(
    'expectedWordCount',
  );
  @override
  late final GeneratedColumn<int> expectedWordCount = GeneratedColumn<int>(
    'expected_word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planning'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    parentId,
    title,
    description,
    expectedWordCount,
    type,
    sortOrder,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outline_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbOutlineNode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('expected_word_count')) {
      context.handle(
        _expectedWordCountMeta,
        expectedWordCount.isAcceptableOrUnknown(
          data['expected_word_count']!,
          _expectedWordCountMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOutlineNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOutlineNode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      expectedWordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_word_count'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OutlineNodesTable createAlias(String alias) {
    return $OutlineNodesTable(attachedDatabase, alias);
  }
}

class DbOutlineNode extends DataClass implements Insertable<DbOutlineNode> {
  final String id;
  final String? bookId;
  final String? parentId;
  final String title;
  final String description;
  final int expectedWordCount;
  final String type;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbOutlineNode({
    required this.id,
    this.bookId,
    this.parentId,
    required this.title,
    required this.description,
    required this.expectedWordCount,
    required this.type,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<String>(bookId);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['expected_word_count'] = Variable<int>(expectedWordCount);
    map['type'] = Variable<String>(type);
    map['sort_order'] = Variable<int>(sortOrder);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OutlineNodesCompanion toCompanion(bool nullToAbsent) {
    return OutlineNodesCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      description: Value(description),
      expectedWordCount: Value(expectedWordCount),
      type: Value(type),
      sortOrder: Value(sortOrder),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbOutlineNode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOutlineNode(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String?>(json['bookId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      expectedWordCount: serializer.fromJson<int>(json['expectedWordCount']),
      type: serializer.fromJson<String>(json['type']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String?>(bookId),
      'parentId': serializer.toJson<String?>(parentId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'expectedWordCount': serializer.toJson<int>(expectedWordCount),
      'type': serializer.toJson<String>(type),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbOutlineNode copyWith({
    String? id,
    Value<String?> bookId = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    String? title,
    String? description,
    int? expectedWordCount,
    String? type,
    int? sortOrder,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbOutlineNode(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    parentId: parentId.present ? parentId.value : this.parentId,
    title: title ?? this.title,
    description: description ?? this.description,
    expectedWordCount: expectedWordCount ?? this.expectedWordCount,
    type: type ?? this.type,
    sortOrder: sortOrder ?? this.sortOrder,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbOutlineNode copyWithCompanion(OutlineNodesCompanion data) {
    return DbOutlineNode(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      expectedWordCount: data.expectedWordCount.present
          ? data.expectedWordCount.value
          : this.expectedWordCount,
      type: data.type.present ? data.type.value : this.type,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOutlineNode(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('expectedWordCount: $expectedWordCount, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    parentId,
    title,
    description,
    expectedWordCount,
    type,
    sortOrder,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOutlineNode &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.description == this.description &&
          other.expectedWordCount == this.expectedWordCount &&
          other.type == this.type &&
          other.sortOrder == this.sortOrder &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OutlineNodesCompanion extends UpdateCompanion<DbOutlineNode> {
  final Value<String> id;
  final Value<String?> bookId;
  final Value<String?> parentId;
  final Value<String> title;
  final Value<String> description;
  final Value<int> expectedWordCount;
  final Value<String> type;
  final Value<int> sortOrder;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OutlineNodesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.expectedWordCount = const Value.absent(),
    this.type = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutlineNodesCompanion.insert({
    required String id,
    this.bookId = const Value.absent(),
    this.parentId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.expectedWordCount = const Value.absent(),
    this.type = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<DbOutlineNode> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? parentId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? expectedWordCount,
    Expression<String>? type,
    Expression<int>? sortOrder,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (expectedWordCount != null) 'expected_word_count': expectedWordCount,
      if (type != null) 'type': type,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutlineNodesCompanion copyWith({
    Value<String>? id,
    Value<String?>? bookId,
    Value<String?>? parentId,
    Value<String>? title,
    Value<String>? description,
    Value<int>? expectedWordCount,
    Value<String>? type,
    Value<int>? sortOrder,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OutlineNodesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      expectedWordCount: expectedWordCount ?? this.expectedWordCount,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (expectedWordCount.present) {
      map['expected_word_count'] = Variable<int>(expectedWordCount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutlineNodesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('expectedWordCount: $expectedWordCount, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, DbCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _personalityTagsMeta = const VerificationMeta(
    'personalityTags',
  );
  @override
  late final GeneratedColumn<String> personalityTags = GeneratedColumn<String>(
    'personality_tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _appearanceMeta = const VerificationMeta(
    'appearance',
  );
  @override
  late final GeneratedColumn<String> appearance = GeneratedColumn<String>(
    'appearance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _backgroundMeta = const VerificationMeta(
    'background',
  );
  @override
  late final GeneratedColumn<String> background = GeneratedColumn<String>(
    'background',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currentStatusMeta = const VerificationMeta(
    'currentStatus',
  );
  @override
  late final GeneratedColumn<String> currentStatus = GeneratedColumn<String>(
    'current_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeadMeta = const VerificationMeta('isDead');
  @override
  late final GeneratedColumn<bool> isDead = GeneratedColumn<bool>(
    'is_dead',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dead" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    aliases,
    personalityTags,
    appearance,
    background,
    currentStatus,
    locationId,
    isDead,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    if (data.containsKey('personality_tags')) {
      context.handle(
        _personalityTagsMeta,
        personalityTags.isAcceptableOrUnknown(
          data['personality_tags']!,
          _personalityTagsMeta,
        ),
      );
    }
    if (data.containsKey('appearance')) {
      context.handle(
        _appearanceMeta,
        appearance.isAcceptableOrUnknown(data['appearance']!, _appearanceMeta),
      );
    }
    if (data.containsKey('background')) {
      context.handle(
        _backgroundMeta,
        background.isAcceptableOrUnknown(data['background']!, _backgroundMeta),
      );
    }
    if (data.containsKey('current_status')) {
      context.handle(
        _currentStatusMeta,
        currentStatus.isAcceptableOrUnknown(
          data['current_status']!,
          _currentStatusMeta,
        ),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('is_dead')) {
      context.handle(
        _isDeadMeta,
        isDead.isAcceptableOrUnknown(data['is_dead']!, _isDeadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCharacter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      )!,
      personalityTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personality_tags'],
      )!,
      appearance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appearance'],
      )!,
      background: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background'],
      )!,
      currentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_status'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      isDead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dead'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class DbCharacter extends DataClass implements Insertable<DbCharacter> {
  final String id;
  final String? bookId;
  final String name;
  final String aliases;
  final String personalityTags;
  final String appearance;
  final String background;
  final String currentStatus;
  final String? locationId;
  final bool isDead;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbCharacter({
    required this.id,
    this.bookId,
    required this.name,
    required this.aliases,
    required this.personalityTags,
    required this.appearance,
    required this.background,
    required this.currentStatus,
    this.locationId,
    required this.isDead,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<String>(bookId);
    }
    map['name'] = Variable<String>(name);
    map['aliases'] = Variable<String>(aliases);
    map['personality_tags'] = Variable<String>(personalityTags);
    map['appearance'] = Variable<String>(appearance);
    map['background'] = Variable<String>(background);
    map['current_status'] = Variable<String>(currentStatus);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    map['is_dead'] = Variable<bool>(isDead);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      name: Value(name),
      aliases: Value(aliases),
      personalityTags: Value(personalityTags),
      appearance: Value(appearance),
      background: Value(background),
      currentStatus: Value(currentStatus),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      isDead: Value(isDead),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCharacter(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String?>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      aliases: serializer.fromJson<String>(json['aliases']),
      personalityTags: serializer.fromJson<String>(json['personalityTags']),
      appearance: serializer.fromJson<String>(json['appearance']),
      background: serializer.fromJson<String>(json['background']),
      currentStatus: serializer.fromJson<String>(json['currentStatus']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      isDead: serializer.fromJson<bool>(json['isDead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String?>(bookId),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<String>(aliases),
      'personalityTags': serializer.toJson<String>(personalityTags),
      'appearance': serializer.toJson<String>(appearance),
      'background': serializer.toJson<String>(background),
      'currentStatus': serializer.toJson<String>(currentStatus),
      'locationId': serializer.toJson<String?>(locationId),
      'isDead': serializer.toJson<bool>(isDead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbCharacter copyWith({
    String? id,
    Value<String?> bookId = const Value.absent(),
    String? name,
    String? aliases,
    String? personalityTags,
    String? appearance,
    String? background,
    String? currentStatus,
    Value<String?> locationId = const Value.absent(),
    bool? isDead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbCharacter(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    name: name ?? this.name,
    aliases: aliases ?? this.aliases,
    personalityTags: personalityTags ?? this.personalityTags,
    appearance: appearance ?? this.appearance,
    background: background ?? this.background,
    currentStatus: currentStatus ?? this.currentStatus,
    locationId: locationId.present ? locationId.value : this.locationId,
    isDead: isDead ?? this.isDead,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbCharacter copyWithCompanion(CharactersCompanion data) {
    return DbCharacter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      personalityTags: data.personalityTags.present
          ? data.personalityTags.value
          : this.personalityTags,
      appearance: data.appearance.present
          ? data.appearance.value
          : this.appearance,
      background: data.background.present
          ? data.background.value
          : this.background,
      currentStatus: data.currentStatus.present
          ? data.currentStatus.value
          : this.currentStatus,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      isDead: data.isDead.present ? data.isDead.value : this.isDead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCharacter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('personalityTags: $personalityTags, ')
          ..write('appearance: $appearance, ')
          ..write('background: $background, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('locationId: $locationId, ')
          ..write('isDead: $isDead, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    name,
    aliases,
    personalityTags,
    appearance,
    background,
    currentStatus,
    locationId,
    isDead,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCharacter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.aliases == this.aliases &&
          other.personalityTags == this.personalityTags &&
          other.appearance == this.appearance &&
          other.background == this.background &&
          other.currentStatus == this.currentStatus &&
          other.locationId == this.locationId &&
          other.isDead == this.isDead &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CharactersCompanion extends UpdateCompanion<DbCharacter> {
  final Value<String> id;
  final Value<String?> bookId;
  final Value<String> name;
  final Value<String> aliases;
  final Value<String> personalityTags;
  final Value<String> appearance;
  final Value<String> background;
  final Value<String> currentStatus;
  final Value<String?> locationId;
  final Value<bool> isDead;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.personalityTags = const Value.absent(),
    this.appearance = const Value.absent(),
    this.background = const Value.absent(),
    this.currentStatus = const Value.absent(),
    this.locationId = const Value.absent(),
    this.isDead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    this.bookId = const Value.absent(),
    required String name,
    this.aliases = const Value.absent(),
    this.personalityTags = const Value.absent(),
    this.appearance = const Value.absent(),
    this.background = const Value.absent(),
    this.currentStatus = const Value.absent(),
    this.locationId = const Value.absent(),
    this.isDead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbCharacter> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<String>? personalityTags,
    Expression<String>? appearance,
    Expression<String>? background,
    Expression<String>? currentStatus,
    Expression<String>? locationId,
    Expression<bool>? isDead,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (personalityTags != null) 'personality_tags': personalityTags,
      if (appearance != null) 'appearance': appearance,
      if (background != null) 'background': background,
      if (currentStatus != null) 'current_status': currentStatus,
      if (locationId != null) 'location_id': locationId,
      if (isDead != null) 'is_dead': isDead,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String?>? bookId,
    Value<String>? name,
    Value<String>? aliases,
    Value<String>? personalityTags,
    Value<String>? appearance,
    Value<String>? background,
    Value<String>? currentStatus,
    Value<String?>? locationId,
    Value<bool>? isDead,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      personalityTags: personalityTags ?? this.personalityTags,
      appearance: appearance ?? this.appearance,
      background: background ?? this.background,
      currentStatus: currentStatus ?? this.currentStatus,
      locationId: locationId ?? this.locationId,
      isDead: isDead ?? this.isDead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (personalityTags.present) {
      map['personality_tags'] = Variable<String>(personalityTags.value);
    }
    if (appearance.present) {
      map['appearance'] = Variable<String>(appearance.value);
    }
    if (background.present) {
      map['background'] = Variable<String>(background.value);
    }
    if (currentStatus.present) {
      map['current_status'] = Variable<String>(currentStatus.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (isDead.present) {
      map['is_dead'] = Variable<bool>(isDead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('personalityTags: $personalityTags, ')
          ..write('appearance: $appearance, ')
          ..write('background: $background, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('locationId: $locationId, ')
          ..write('isDead: $isDead, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterChapterLogsTable extends CharacterChapterLogs
    with TableInfo<$CharacterChapterLogsTable, DbCharacterChapterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterChapterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusChangedFromMeta = const VerificationMeta(
    'statusChangedFrom',
  );
  @override
  late final GeneratedColumn<String> statusChangedFrom =
      GeneratedColumn<String>(
        'status_changed_from',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _statusChangedToMeta = const VerificationMeta(
    'statusChangedTo',
  );
  @override
  late final GeneratedColumn<String> statusChangedTo = GeneratedColumn<String>(
    'status_changed_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    characterId,
    chapterId,
    summary,
    statusChangedFrom,
    statusChangedTo,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_chapter_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCharacterChapterLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('status_changed_from')) {
      context.handle(
        _statusChangedFromMeta,
        statusChangedFrom.isAcceptableOrUnknown(
          data['status_changed_from']!,
          _statusChangedFromMeta,
        ),
      );
    }
    if (data.containsKey('status_changed_to')) {
      context.handle(
        _statusChangedToMeta,
        statusChangedTo.isAcceptableOrUnknown(
          data['status_changed_to']!,
          _statusChangedToMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCharacterChapterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCharacterChapterLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      statusChangedFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_changed_from'],
      )!,
      statusChangedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_changed_to'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CharacterChapterLogsTable createAlias(String alias) {
    return $CharacterChapterLogsTable(attachedDatabase, alias);
  }
}

class DbCharacterChapterLog extends DataClass
    implements Insertable<DbCharacterChapterLog> {
  final String id;
  final String characterId;
  final String chapterId;
  final String summary;
  final String statusChangedFrom;
  final String statusChangedTo;
  final int sortOrder;
  const DbCharacterChapterLog({
    required this.id,
    required this.characterId,
    required this.chapterId,
    required this.summary,
    required this.statusChangedFrom,
    required this.statusChangedTo,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character_id'] = Variable<String>(characterId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['summary'] = Variable<String>(summary);
    map['status_changed_from'] = Variable<String>(statusChangedFrom);
    map['status_changed_to'] = Variable<String>(statusChangedTo);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CharacterChapterLogsCompanion toCompanion(bool nullToAbsent) {
    return CharacterChapterLogsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      chapterId: Value(chapterId),
      summary: Value(summary),
      statusChangedFrom: Value(statusChangedFrom),
      statusChangedTo: Value(statusChangedTo),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbCharacterChapterLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCharacterChapterLog(
      id: serializer.fromJson<String>(json['id']),
      characterId: serializer.fromJson<String>(json['characterId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      summary: serializer.fromJson<String>(json['summary']),
      statusChangedFrom: serializer.fromJson<String>(json['statusChangedFrom']),
      statusChangedTo: serializer.fromJson<String>(json['statusChangedTo']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'characterId': serializer.toJson<String>(characterId),
      'chapterId': serializer.toJson<String>(chapterId),
      'summary': serializer.toJson<String>(summary),
      'statusChangedFrom': serializer.toJson<String>(statusChangedFrom),
      'statusChangedTo': serializer.toJson<String>(statusChangedTo),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbCharacterChapterLog copyWith({
    String? id,
    String? characterId,
    String? chapterId,
    String? summary,
    String? statusChangedFrom,
    String? statusChangedTo,
    int? sortOrder,
  }) => DbCharacterChapterLog(
    id: id ?? this.id,
    characterId: characterId ?? this.characterId,
    chapterId: chapterId ?? this.chapterId,
    summary: summary ?? this.summary,
    statusChangedFrom: statusChangedFrom ?? this.statusChangedFrom,
    statusChangedTo: statusChangedTo ?? this.statusChangedTo,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DbCharacterChapterLog copyWithCompanion(CharacterChapterLogsCompanion data) {
    return DbCharacterChapterLog(
      id: data.id.present ? data.id.value : this.id,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      summary: data.summary.present ? data.summary.value : this.summary,
      statusChangedFrom: data.statusChangedFrom.present
          ? data.statusChangedFrom.value
          : this.statusChangedFrom,
      statusChangedTo: data.statusChangedTo.present
          ? data.statusChangedTo.value
          : this.statusChangedTo,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCharacterChapterLog(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('chapterId: $chapterId, ')
          ..write('summary: $summary, ')
          ..write('statusChangedFrom: $statusChangedFrom, ')
          ..write('statusChangedTo: $statusChangedTo, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    characterId,
    chapterId,
    summary,
    statusChangedFrom,
    statusChangedTo,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCharacterChapterLog &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.chapterId == this.chapterId &&
          other.summary == this.summary &&
          other.statusChangedFrom == this.statusChangedFrom &&
          other.statusChangedTo == this.statusChangedTo &&
          other.sortOrder == this.sortOrder);
}

class CharacterChapterLogsCompanion
    extends UpdateCompanion<DbCharacterChapterLog> {
  final Value<String> id;
  final Value<String> characterId;
  final Value<String> chapterId;
  final Value<String> summary;
  final Value<String> statusChangedFrom;
  final Value<String> statusChangedTo;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CharacterChapterLogsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.summary = const Value.absent(),
    this.statusChangedFrom = const Value.absent(),
    this.statusChangedTo = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterChapterLogsCompanion.insert({
    required String id,
    required String characterId,
    required String chapterId,
    this.summary = const Value.absent(),
    this.statusChangedFrom = const Value.absent(),
    this.statusChangedTo = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       characterId = Value(characterId),
       chapterId = Value(chapterId);
  static Insertable<DbCharacterChapterLog> custom({
    Expression<String>? id,
    Expression<String>? characterId,
    Expression<String>? chapterId,
    Expression<String>? summary,
    Expression<String>? statusChangedFrom,
    Expression<String>? statusChangedTo,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (summary != null) 'summary': summary,
      if (statusChangedFrom != null) 'status_changed_from': statusChangedFrom,
      if (statusChangedTo != null) 'status_changed_to': statusChangedTo,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterChapterLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? characterId,
    Value<String>? chapterId,
    Value<String>? summary,
    Value<String>? statusChangedFrom,
    Value<String>? statusChangedTo,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CharacterChapterLogsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      chapterId: chapterId ?? this.chapterId,
      summary: summary ?? this.summary,
      statusChangedFrom: statusChangedFrom ?? this.statusChangedFrom,
      statusChangedTo: statusChangedTo ?? this.statusChangedTo,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (statusChangedFrom.present) {
      map['status_changed_from'] = Variable<String>(statusChangedFrom.value);
    }
    if (statusChangedTo.present) {
      map['status_changed_to'] = Variable<String>(statusChangedTo.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterChapterLogsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('chapterId: $chapterId, ')
          ..write('summary: $summary, ')
          ..write('statusChangedFrom: $statusChangedFrom, ')
          ..write('statusChangedTo: $statusChangedTo, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorldEntriesTable extends WorldEntries
    with TableInfo<$WorldEntriesTable, DbWorldEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorldEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryTagIdMeta = const VerificationMeta(
    'categoryTagId',
  );
  @override
  late final GeneratedColumn<String> categoryTagId = GeneratedColumn<String>(
    'category_tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flexibleJsonMeta = const VerificationMeta(
    'flexibleJson',
  );
  @override
  late final GeneratedColumn<String> flexibleJson = GeneratedColumn<String>(
    'flexible_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    description,
    categoryTagId,
    flexibleJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'world_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbWorldEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('category_tag_id')) {
      context.handle(
        _categoryTagIdMeta,
        categoryTagId.isAcceptableOrUnknown(
          data['category_tag_id']!,
          _categoryTagIdMeta,
        ),
      );
    }
    if (data.containsKey('flexible_json')) {
      context.handle(
        _flexibleJsonMeta,
        flexibleJson.isAcceptableOrUnknown(
          data['flexible_json']!,
          _flexibleJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbWorldEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbWorldEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_tag_id'],
      ),
      flexibleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flexible_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorldEntriesTable createAlias(String alias) {
    return $WorldEntriesTable(attachedDatabase, alias);
  }
}

class DbWorldEntry extends DataClass implements Insertable<DbWorldEntry> {
  final String id;
  final String? bookId;
  final String name;
  final String description;
  final String? categoryTagId;
  final String flexibleJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbWorldEntry({
    required this.id,
    this.bookId,
    required this.name,
    required this.description,
    this.categoryTagId,
    required this.flexibleJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<String>(bookId);
    }
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || categoryTagId != null) {
      map['category_tag_id'] = Variable<String>(categoryTagId);
    }
    map['flexible_json'] = Variable<String>(flexibleJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorldEntriesCompanion toCompanion(bool nullToAbsent) {
    return WorldEntriesCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      name: Value(name),
      description: Value(description),
      categoryTagId: categoryTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryTagId),
      flexibleJson: Value(flexibleJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbWorldEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbWorldEntry(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String?>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      categoryTagId: serializer.fromJson<String?>(json['categoryTagId']),
      flexibleJson: serializer.fromJson<String>(json['flexibleJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String?>(bookId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'categoryTagId': serializer.toJson<String?>(categoryTagId),
      'flexibleJson': serializer.toJson<String>(flexibleJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbWorldEntry copyWith({
    String? id,
    Value<String?> bookId = const Value.absent(),
    String? name,
    String? description,
    Value<String?> categoryTagId = const Value.absent(),
    String? flexibleJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbWorldEntry(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    name: name ?? this.name,
    description: description ?? this.description,
    categoryTagId: categoryTagId.present
        ? categoryTagId.value
        : this.categoryTagId,
    flexibleJson: flexibleJson ?? this.flexibleJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbWorldEntry copyWithCompanion(WorldEntriesCompanion data) {
    return DbWorldEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryTagId: data.categoryTagId.present
          ? data.categoryTagId.value
          : this.categoryTagId,
      flexibleJson: data.flexibleJson.present
          ? data.flexibleJson.value
          : this.flexibleJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbWorldEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryTagId: $categoryTagId, ')
          ..write('flexibleJson: $flexibleJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    name,
    description,
    categoryTagId,
    flexibleJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbWorldEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.description == this.description &&
          other.categoryTagId == this.categoryTagId &&
          other.flexibleJson == this.flexibleJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorldEntriesCompanion extends UpdateCompanion<DbWorldEntry> {
  final Value<String> id;
  final Value<String?> bookId;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> categoryTagId;
  final Value<String> flexibleJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorldEntriesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryTagId = const Value.absent(),
    this.flexibleJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorldEntriesCompanion.insert({
    required String id,
    this.bookId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.categoryTagId = const Value.absent(),
    this.flexibleJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbWorldEntry> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? categoryTagId,
    Expression<String>? flexibleJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (categoryTagId != null) 'category_tag_id': categoryTagId,
      if (flexibleJson != null) 'flexible_json': flexibleJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorldEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? bookId,
    Value<String>? name,
    Value<String>? description,
    Value<String?>? categoryTagId,
    Value<String>? flexibleJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorldEntriesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryTagId: categoryTagId ?? this.categoryTagId,
      flexibleJson: flexibleJson ?? this.flexibleJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryTagId.present) {
      map['category_tag_id'] = Variable<String>(categoryTagId.value);
    }
    if (flexibleJson.present) {
      map['flexible_json'] = Variable<String>(flexibleJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorldEntriesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryTagId: $categoryTagId, ')
          ..write('flexibleJson: $flexibleJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InspirationsTable extends Inspirations
    with TableInfo<$InspirationsTable, DbInspiration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InspirationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    level,
    title,
    content,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inspirations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbInspiration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DbInspiration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbInspiration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InspirationsTable createAlias(String alias) {
    return $InspirationsTable(attachedDatabase, alias);
  }
}

class DbInspiration extends DataClass implements Insertable<DbInspiration> {
  final String id;
  final String? bookId;
  final String level;
  final String title;
  final String content;
  final String source;
  final DateTime createdAt;
  const DbInspiration({
    required this.id,
    this.bookId,
    required this.level,
    required this.title,
    required this.content,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<String>(bookId);
    }
    map['level'] = Variable<String>(level);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InspirationsCompanion toCompanion(bool nullToAbsent) {
    return InspirationsCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      level: Value(level),
      title: Value(title),
      content: Value(content),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory DbInspiration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbInspiration(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String?>(json['bookId']),
      level: serializer.fromJson<String>(json['level']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String?>(bookId),
      'level': serializer.toJson<String>(level),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbInspiration copyWith({
    String? id,
    Value<String?> bookId = const Value.absent(),
    String? level,
    String? title,
    String? content,
    String? source,
    DateTime? createdAt,
  }) => DbInspiration(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    level: level ?? this.level,
    title: title ?? this.title,
    content: content ?? this.content,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  DbInspiration copyWithCompanion(InspirationsCompanion data) {
    return DbInspiration(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      level: data.level.present ? data.level.value : this.level,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbInspiration(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, level, title, content, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbInspiration &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.level == this.level &&
          other.title == this.title &&
          other.content == this.content &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class InspirationsCompanion extends UpdateCompanion<DbInspiration> {
  final Value<String> id;
  final Value<String?> bookId;
  final Value<String> level;
  final Value<String> title;
  final Value<String> content;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InspirationsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.level = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InspirationsCompanion.insert({
    required String id,
    this.bookId = const Value.absent(),
    required String level,
    required String title,
    this.content = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       level = Value(level),
       title = Value(title);
  static Insertable<DbInspiration> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? level,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (level != null) 'level': level,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InspirationsCompanion copyWith({
    Value<String>? id,
    Value<String?>? bookId,
    Value<String>? level,
    Value<String>? title,
    Value<String>? content,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InspirationsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      level: level ?? this.level,
      title: title ?? this.title,
      content: content ?? this.content,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InspirationsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, DbItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _abilitiesMeta = const VerificationMeta(
    'abilities',
  );
  @override
  late final GeneratedColumn<String> abilities = GeneratedColumn<String>(
    'abilities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isUniqueMeta = const VerificationMeta(
    'isUnique',
  );
  @override
  late final GeneratedColumn<bool> isUnique = GeneratedColumn<bool>(
    'is_unique',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unique" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentHolderIdMeta = const VerificationMeta(
    'currentHolderId',
  );
  @override
  late final GeneratedColumn<String> currentHolderId = GeneratedColumn<String>(
    'current_holder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    description,
    abilities,
    isUnique,
    currentHolderId,
    location,
    quantity,
    origin,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('abilities')) {
      context.handle(
        _abilitiesMeta,
        abilities.isAcceptableOrUnknown(data['abilities']!, _abilitiesMeta),
      );
    }
    if (data.containsKey('is_unique')) {
      context.handle(
        _isUniqueMeta,
        isUnique.isAcceptableOrUnknown(data['is_unique']!, _isUniqueMeta),
      );
    }
    if (data.containsKey('current_holder_id')) {
      context.handle(
        _currentHolderIdMeta,
        currentHolderId.isAcceptableOrUnknown(
          data['current_holder_id']!,
          _currentHolderIdMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      abilities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abilities'],
      )!,
      isUnique: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unique'],
      )!,
      currentHolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_holder_id'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class DbItem extends DataClass implements Insertable<DbItem> {
  final String id;
  final String? bookId;
  final String name;
  final String description;
  final String abilities;
  final bool isUnique;
  final String? currentHolderId;
  final String location;
  final int quantity;
  final String origin;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbItem({
    required this.id,
    this.bookId,
    required this.name,
    required this.description,
    required this.abilities,
    required this.isUnique,
    this.currentHolderId,
    required this.location,
    required this.quantity,
    required this.origin,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<String>(bookId);
    }
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['abilities'] = Variable<String>(abilities);
    map['is_unique'] = Variable<bool>(isUnique);
    if (!nullToAbsent || currentHolderId != null) {
      map['current_holder_id'] = Variable<String>(currentHolderId);
    }
    map['location'] = Variable<String>(location);
    map['quantity'] = Variable<int>(quantity);
    map['origin'] = Variable<String>(origin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      name: Value(name),
      description: Value(description),
      abilities: Value(abilities),
      isUnique: Value(isUnique),
      currentHolderId: currentHolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentHolderId),
      location: Value(location),
      quantity: Value(quantity),
      origin: Value(origin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbItem(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String?>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      abilities: serializer.fromJson<String>(json['abilities']),
      isUnique: serializer.fromJson<bool>(json['isUnique']),
      currentHolderId: serializer.fromJson<String?>(json['currentHolderId']),
      location: serializer.fromJson<String>(json['location']),
      quantity: serializer.fromJson<int>(json['quantity']),
      origin: serializer.fromJson<String>(json['origin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String?>(bookId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'abilities': serializer.toJson<String>(abilities),
      'isUnique': serializer.toJson<bool>(isUnique),
      'currentHolderId': serializer.toJson<String?>(currentHolderId),
      'location': serializer.toJson<String>(location),
      'quantity': serializer.toJson<int>(quantity),
      'origin': serializer.toJson<String>(origin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbItem copyWith({
    String? id,
    Value<String?> bookId = const Value.absent(),
    String? name,
    String? description,
    String? abilities,
    bool? isUnique,
    Value<String?> currentHolderId = const Value.absent(),
    String? location,
    int? quantity,
    String? origin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbItem(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    name: name ?? this.name,
    description: description ?? this.description,
    abilities: abilities ?? this.abilities,
    isUnique: isUnique ?? this.isUnique,
    currentHolderId: currentHolderId.present
        ? currentHolderId.value
        : this.currentHolderId,
    location: location ?? this.location,
    quantity: quantity ?? this.quantity,
    origin: origin ?? this.origin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbItem copyWithCompanion(ItemsCompanion data) {
    return DbItem(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      abilities: data.abilities.present ? data.abilities.value : this.abilities,
      isUnique: data.isUnique.present ? data.isUnique.value : this.isUnique,
      currentHolderId: data.currentHolderId.present
          ? data.currentHolderId.value
          : this.currentHolderId,
      location: data.location.present ? data.location.value : this.location,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      origin: data.origin.present ? data.origin.value : this.origin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbItem(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('abilities: $abilities, ')
          ..write('isUnique: $isUnique, ')
          ..write('currentHolderId: $currentHolderId, ')
          ..write('location: $location, ')
          ..write('quantity: $quantity, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    name,
    description,
    abilities,
    isUnique,
    currentHolderId,
    location,
    quantity,
    origin,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbItem &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.description == this.description &&
          other.abilities == this.abilities &&
          other.isUnique == this.isUnique &&
          other.currentHolderId == this.currentHolderId &&
          other.location == this.location &&
          other.quantity == this.quantity &&
          other.origin == this.origin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<DbItem> {
  final Value<String> id;
  final Value<String?> bookId;
  final Value<String> name;
  final Value<String> description;
  final Value<String> abilities;
  final Value<bool> isUnique;
  final Value<String?> currentHolderId;
  final Value<String> location;
  final Value<int> quantity;
  final Value<String> origin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.abilities = const Value.absent(),
    this.isUnique = const Value.absent(),
    this.currentHolderId = const Value.absent(),
    this.location = const Value.absent(),
    this.quantity = const Value.absent(),
    this.origin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    this.bookId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.abilities = const Value.absent(),
    this.isUnique = const Value.absent(),
    this.currentHolderId = const Value.absent(),
    this.location = const Value.absent(),
    this.quantity = const Value.absent(),
    this.origin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbItem> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? abilities,
    Expression<bool>? isUnique,
    Expression<String>? currentHolderId,
    Expression<String>? location,
    Expression<int>? quantity,
    Expression<String>? origin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (abilities != null) 'abilities': abilities,
      if (isUnique != null) 'is_unique': isUnique,
      if (currentHolderId != null) 'current_holder_id': currentHolderId,
      if (location != null) 'location': location,
      if (quantity != null) 'quantity': quantity,
      if (origin != null) 'origin': origin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String?>? bookId,
    Value<String>? name,
    Value<String>? description,
    Value<String>? abilities,
    Value<bool>? isUnique,
    Value<String?>? currentHolderId,
    Value<String>? location,
    Value<int>? quantity,
    Value<String>? origin,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      description: description ?? this.description,
      abilities: abilities ?? this.abilities,
      isUnique: isUnique ?? this.isUnique,
      currentHolderId: currentHolderId ?? this.currentHolderId,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      origin: origin ?? this.origin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (abilities.present) {
      map['abilities'] = Variable<String>(abilities.value);
    }
    if (isUnique.present) {
      map['is_unique'] = Variable<bool>(isUnique.value);
    }
    if (currentHolderId.present) {
      map['current_holder_id'] = Variable<String>(currentHolderId.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('abilities: $abilities, ')
          ..write('isUnique: $isUnique, ')
          ..write('currentHolderId: $currentHolderId, ')
          ..write('location: $location, ')
          ..write('quantity: $quantity, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $VolumesTable volumes = $VolumesTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $EntityLinksTable entityLinks = $EntityLinksTable(this);
  late final $StyleProfilesTable styleProfiles = $StyleProfilesTable(this);
  late final $CategoryTagsTable categoryTags = $CategoryTagsTable(this);
  late final $OutlineNodesTable outlineNodes = $OutlineNodesTable(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $CharacterChapterLogsTable characterChapterLogs =
      $CharacterChapterLogsTable(this);
  late final $WorldEntriesTable worldEntries = $WorldEntriesTable(this);
  late final $InspirationsTable inspirations = $InspirationsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    volumes,
    chapters,
    entityLinks,
    styleProfiles,
    categoryTags,
    outlineNodes,
    characters,
    characterChapterLogs,
    worldEntries,
    inspirations,
    items,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      required String name,
      Value<String?> path,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> path,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          DbBook,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (DbBook, BaseReferences<_$AppDatabase, $BooksTable, DbBook>),
          DbBook,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                name: name,
                path: path,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> path = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                name: name,
                path: path,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      DbBook,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (DbBook, BaseReferences<_$AppDatabase, $BooksTable, DbBook>),
      DbBook,
      PrefetchHooks Function()
    >;
typedef $$VolumesTableCreateCompanionBuilder =
    VolumesCompanion Function({
      required String id,
      required String bookId,
      required String name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$VolumesTableUpdateCompanionBuilder =
    VolumesCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$VolumesTableFilterComposer
    extends Composer<_$AppDatabase, $VolumesTable> {
  $$VolumesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VolumesTableOrderingComposer
    extends Composer<_$AppDatabase, $VolumesTable> {
  $$VolumesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VolumesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VolumesTable> {
  $$VolumesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VolumesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VolumesTable,
          DbVolume,
          $$VolumesTableFilterComposer,
          $$VolumesTableOrderingComposer,
          $$VolumesTableAnnotationComposer,
          $$VolumesTableCreateCompanionBuilder,
          $$VolumesTableUpdateCompanionBuilder,
          (DbVolume, BaseReferences<_$AppDatabase, $VolumesTable, DbVolume>),
          DbVolume,
          PrefetchHooks Function()
        > {
  $$VolumesTableTableManager(_$AppDatabase db, $VolumesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VolumesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VolumesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VolumesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VolumesCompanion(
                id: id,
                bookId: bookId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VolumesCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VolumesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VolumesTable,
      DbVolume,
      $$VolumesTableFilterComposer,
      $$VolumesTableOrderingComposer,
      $$VolumesTableAnnotationComposer,
      $$VolumesTableCreateCompanionBuilder,
      $$VolumesTableUpdateCompanionBuilder,
      (DbVolume, BaseReferences<_$AppDatabase, $VolumesTable, DbVolume>),
      DbVolume,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      required String id,
      required String volumeId,
      required String name,
      Value<String?> filePath,
      Value<int> sortOrder,
      Value<String> summary,
      Value<String> status,
      Value<int> wordCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<String> id,
      Value<String> volumeId,
      Value<String> name,
      Value<String?> filePath,
      Value<int> sortOrder,
      Value<String> summary,
      Value<String> status,
      Value<int> wordCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeId => $composableBuilder(
    column: $table.volumeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeId => $composableBuilder(
    column: $table.volumeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get volumeId =>
      $composableBuilder(column: $table.volumeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          DbChapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (DbChapter, BaseReferences<_$AppDatabase, $ChaptersTable, DbChapter>),
          DbChapter,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> volumeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                volumeId: volumeId,
                name: name,
                filePath: filePath,
                sortOrder: sortOrder,
                summary: summary,
                status: status,
                wordCount: wordCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String volumeId,
                required String name,
                Value<String?> filePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                volumeId: volumeId,
                name: name,
                filePath: filePath,
                sortOrder: sortOrder,
                summary: summary,
                status: status,
                wordCount: wordCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      DbChapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (DbChapter, BaseReferences<_$AppDatabase, $ChaptersTable, DbChapter>),
      DbChapter,
      PrefetchHooks Function()
    >;
typedef $$EntityLinksTableCreateCompanionBuilder =
    EntityLinksCompanion Function({
      Value<int> id,
      required String fromType,
      required String fromId,
      required String toType,
      required String toId,
      required String linkType,
      Value<String> metadata,
      Value<DateTime> createdAt,
    });
typedef $$EntityLinksTableUpdateCompanionBuilder =
    EntityLinksCompanion Function({
      Value<int> id,
      Value<String> fromType,
      Value<String> fromId,
      Value<String> toType,
      Value<String> toId,
      Value<String> linkType,
      Value<String> metadata,
      Value<DateTime> createdAt,
    });

class $$EntityLinksTableFilterComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableFilterComposer({
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

  ColumnFilters<String> get fromType => $composableBuilder(
    column: $table.fromType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toType => $composableBuilder(
    column: $table.toType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkType => $composableBuilder(
    column: $table.linkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableOrderingComposer({
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

  ColumnOrderings<String> get fromType => $composableBuilder(
    column: $table.fromType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toType => $composableBuilder(
    column: $table.toType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkType => $composableBuilder(
    column: $table.linkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromType =>
      $composableBuilder(column: $table.fromType, builder: (column) => column);

  GeneratedColumn<String> get fromId =>
      $composableBuilder(column: $table.fromId, builder: (column) => column);

  GeneratedColumn<String> get toType =>
      $composableBuilder(column: $table.toType, builder: (column) => column);

  GeneratedColumn<String> get toId =>
      $composableBuilder(column: $table.toId, builder: (column) => column);

  GeneratedColumn<String> get linkType =>
      $composableBuilder(column: $table.linkType, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EntityLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityLinksTable,
          DbEntityLink,
          $$EntityLinksTableFilterComposer,
          $$EntityLinksTableOrderingComposer,
          $$EntityLinksTableAnnotationComposer,
          $$EntityLinksTableCreateCompanionBuilder,
          $$EntityLinksTableUpdateCompanionBuilder,
          (
            DbEntityLink,
            BaseReferences<_$AppDatabase, $EntityLinksTable, DbEntityLink>,
          ),
          DbEntityLink,
          PrefetchHooks Function()
        > {
  $$EntityLinksTableTableManager(_$AppDatabase db, $EntityLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fromType = const Value.absent(),
                Value<String> fromId = const Value.absent(),
                Value<String> toType = const Value.absent(),
                Value<String> toId = const Value.absent(),
                Value<String> linkType = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntityLinksCompanion(
                id: id,
                fromType: fromType,
                fromId: fromId,
                toType: toType,
                toId: toId,
                linkType: linkType,
                metadata: metadata,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fromType,
                required String fromId,
                required String toType,
                required String toId,
                required String linkType,
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntityLinksCompanion.insert(
                id: id,
                fromType: fromType,
                fromId: fromId,
                toType: toType,
                toId: toId,
                linkType: linkType,
                metadata: metadata,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityLinksTable,
      DbEntityLink,
      $$EntityLinksTableFilterComposer,
      $$EntityLinksTableOrderingComposer,
      $$EntityLinksTableAnnotationComposer,
      $$EntityLinksTableCreateCompanionBuilder,
      $$EntityLinksTableUpdateCompanionBuilder,
      (
        DbEntityLink,
        BaseReferences<_$AppDatabase, $EntityLinksTable, DbEntityLink>,
      ),
      DbEntityLink,
      PrefetchHooks Function()
    >;
typedef $$StyleProfilesTableCreateCompanionBuilder =
    StyleProfilesCompanion Function({
      required String id,
      required String name,
      Value<String> systemPromptTemplate,
      Value<String> exampleText,
      Value<String> parametersJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$StyleProfilesTableUpdateCompanionBuilder =
    StyleProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> systemPromptTemplate,
      Value<String> exampleText,
      Value<String> parametersJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$StyleProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $StyleProfilesTable> {
  $$StyleProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPromptTemplate => $composableBuilder(
    column: $table.systemPromptTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleText => $composableBuilder(
    column: $table.exampleText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StyleProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $StyleProfilesTable> {
  $$StyleProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPromptTemplate => $composableBuilder(
    column: $table.systemPromptTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleText => $composableBuilder(
    column: $table.exampleText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StyleProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StyleProfilesTable> {
  $$StyleProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get systemPromptTemplate => $composableBuilder(
    column: $table.systemPromptTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleText => $composableBuilder(
    column: $table.exampleText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StyleProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StyleProfilesTable,
          DbStyleProfile,
          $$StyleProfilesTableFilterComposer,
          $$StyleProfilesTableOrderingComposer,
          $$StyleProfilesTableAnnotationComposer,
          $$StyleProfilesTableCreateCompanionBuilder,
          $$StyleProfilesTableUpdateCompanionBuilder,
          (
            DbStyleProfile,
            BaseReferences<_$AppDatabase, $StyleProfilesTable, DbStyleProfile>,
          ),
          DbStyleProfile,
          PrefetchHooks Function()
        > {
  $$StyleProfilesTableTableManager(_$AppDatabase db, $StyleProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StyleProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StyleProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StyleProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> systemPromptTemplate = const Value.absent(),
                Value<String> exampleText = const Value.absent(),
                Value<String> parametersJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StyleProfilesCompanion(
                id: id,
                name: name,
                systemPromptTemplate: systemPromptTemplate,
                exampleText: exampleText,
                parametersJson: parametersJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> systemPromptTemplate = const Value.absent(),
                Value<String> exampleText = const Value.absent(),
                Value<String> parametersJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StyleProfilesCompanion.insert(
                id: id,
                name: name,
                systemPromptTemplate: systemPromptTemplate,
                exampleText: exampleText,
                parametersJson: parametersJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StyleProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StyleProfilesTable,
      DbStyleProfile,
      $$StyleProfilesTableFilterComposer,
      $$StyleProfilesTableOrderingComposer,
      $$StyleProfilesTableAnnotationComposer,
      $$StyleProfilesTableCreateCompanionBuilder,
      $$StyleProfilesTableUpdateCompanionBuilder,
      (
        DbStyleProfile,
        BaseReferences<_$AppDatabase, $StyleProfilesTable, DbStyleProfile>,
      ),
      DbStyleProfile,
      PrefetchHooks Function()
    >;
typedef $$CategoryTagsTableCreateCompanionBuilder =
    CategoryTagsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<String> moduleId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CategoryTagsTableUpdateCompanionBuilder =
    CategoryTagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<String> moduleId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CategoryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryTagsTable> {
  $$CategoryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryTagsTable> {
  $$CategoryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryTagsTable> {
  $$CategoryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoryTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryTagsTable,
          DbCategoryTag,
          $$CategoryTagsTableFilterComposer,
          $$CategoryTagsTableOrderingComposer,
          $$CategoryTagsTableAnnotationComposer,
          $$CategoryTagsTableCreateCompanionBuilder,
          $$CategoryTagsTableUpdateCompanionBuilder,
          (
            DbCategoryTag,
            BaseReferences<_$AppDatabase, $CategoryTagsTable, DbCategoryTag>,
          ),
          DbCategoryTag,
          PrefetchHooks Function()
        > {
  $$CategoryTagsTableTableManager(_$AppDatabase db, $CategoryTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryTagsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                moduleId: moduleId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryTagsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                moduleId: moduleId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryTagsTable,
      DbCategoryTag,
      $$CategoryTagsTableFilterComposer,
      $$CategoryTagsTableOrderingComposer,
      $$CategoryTagsTableAnnotationComposer,
      $$CategoryTagsTableCreateCompanionBuilder,
      $$CategoryTagsTableUpdateCompanionBuilder,
      (
        DbCategoryTag,
        BaseReferences<_$AppDatabase, $CategoryTagsTable, DbCategoryTag>,
      ),
      DbCategoryTag,
      PrefetchHooks Function()
    >;
typedef $$OutlineNodesTableCreateCompanionBuilder =
    OutlineNodesCompanion Function({
      required String id,
      Value<String?> bookId,
      Value<String?> parentId,
      required String title,
      Value<String> description,
      Value<int> expectedWordCount,
      Value<String> type,
      Value<int> sortOrder,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$OutlineNodesTableUpdateCompanionBuilder =
    OutlineNodesCompanion Function({
      Value<String> id,
      Value<String?> bookId,
      Value<String?> parentId,
      Value<String> title,
      Value<String> description,
      Value<int> expectedWordCount,
      Value<String> type,
      Value<int> sortOrder,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OutlineNodesTableFilterComposer
    extends Composer<_$AppDatabase, $OutlineNodesTable> {
  $$OutlineNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedWordCount => $composableBuilder(
    column: $table.expectedWordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutlineNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutlineNodesTable> {
  $$OutlineNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedWordCount => $composableBuilder(
    column: $table.expectedWordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutlineNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutlineNodesTable> {
  $$OutlineNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedWordCount => $composableBuilder(
    column: $table.expectedWordCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OutlineNodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutlineNodesTable,
          DbOutlineNode,
          $$OutlineNodesTableFilterComposer,
          $$OutlineNodesTableOrderingComposer,
          $$OutlineNodesTableAnnotationComposer,
          $$OutlineNodesTableCreateCompanionBuilder,
          $$OutlineNodesTableUpdateCompanionBuilder,
          (
            DbOutlineNode,
            BaseReferences<_$AppDatabase, $OutlineNodesTable, DbOutlineNode>,
          ),
          DbOutlineNode,
          PrefetchHooks Function()
        > {
  $$OutlineNodesTableTableManager(_$AppDatabase db, $OutlineNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutlineNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutlineNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutlineNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> bookId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> expectedWordCount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutlineNodesCompanion(
                id: id,
                bookId: bookId,
                parentId: parentId,
                title: title,
                description: description,
                expectedWordCount: expectedWordCount,
                type: type,
                sortOrder: sortOrder,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> bookId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> expectedWordCount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutlineNodesCompanion.insert(
                id: id,
                bookId: bookId,
                parentId: parentId,
                title: title,
                description: description,
                expectedWordCount: expectedWordCount,
                type: type,
                sortOrder: sortOrder,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutlineNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutlineNodesTable,
      DbOutlineNode,
      $$OutlineNodesTableFilterComposer,
      $$OutlineNodesTableOrderingComposer,
      $$OutlineNodesTableAnnotationComposer,
      $$OutlineNodesTableCreateCompanionBuilder,
      $$OutlineNodesTableUpdateCompanionBuilder,
      (
        DbOutlineNode,
        BaseReferences<_$AppDatabase, $OutlineNodesTable, DbOutlineNode>,
      ),
      DbOutlineNode,
      PrefetchHooks Function()
    >;
typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      required String id,
      Value<String?> bookId,
      required String name,
      Value<String> aliases,
      Value<String> personalityTags,
      Value<String> appearance,
      Value<String> background,
      Value<String> currentStatus,
      Value<String?> locationId,
      Value<bool> isDead,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<String> id,
      Value<String?> bookId,
      Value<String> name,
      Value<String> aliases,
      Value<String> personalityTags,
      Value<String> appearance,
      Value<String> background,
      Value<String> currentStatus,
      Value<String?> locationId,
      Value<bool> isDead,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalityTags => $composableBuilder(
    column: $table.personalityTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appearance => $composableBuilder(
    column: $table.appearance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDead => $composableBuilder(
    column: $table.isDead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalityTags => $composableBuilder(
    column: $table.personalityTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appearance => $composableBuilder(
    column: $table.appearance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDead => $composableBuilder(
    column: $table.isDead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get personalityTags => $composableBuilder(
    column: $table.personalityTags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appearance => $composableBuilder(
    column: $table.appearance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDead =>
      $composableBuilder(column: $table.isDead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          DbCharacter,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (
            DbCharacter,
            BaseReferences<_$AppDatabase, $CharactersTable, DbCharacter>,
          ),
          DbCharacter,
          PrefetchHooks Function()
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> aliases = const Value.absent(),
                Value<String> personalityTags = const Value.absent(),
                Value<String> appearance = const Value.absent(),
                Value<String> background = const Value.absent(),
                Value<String> currentStatus = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<bool> isDead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                bookId: bookId,
                name: name,
                aliases: aliases,
                personalityTags: personalityTags,
                appearance: appearance,
                background: background,
                currentStatus: currentStatus,
                locationId: locationId,
                isDead: isDead,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> bookId = const Value.absent(),
                required String name,
                Value<String> aliases = const Value.absent(),
                Value<String> personalityTags = const Value.absent(),
                Value<String> appearance = const Value.absent(),
                Value<String> background = const Value.absent(),
                Value<String> currentStatus = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<bool> isDead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                aliases: aliases,
                personalityTags: personalityTags,
                appearance: appearance,
                background: background,
                currentStatus: currentStatus,
                locationId: locationId,
                isDead: isDead,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      DbCharacter,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (
        DbCharacter,
        BaseReferences<_$AppDatabase, $CharactersTable, DbCharacter>,
      ),
      DbCharacter,
      PrefetchHooks Function()
    >;
typedef $$CharacterChapterLogsTableCreateCompanionBuilder =
    CharacterChapterLogsCompanion Function({
      required String id,
      required String characterId,
      required String chapterId,
      Value<String> summary,
      Value<String> statusChangedFrom,
      Value<String> statusChangedTo,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CharacterChapterLogsTableUpdateCompanionBuilder =
    CharacterChapterLogsCompanion Function({
      Value<String> id,
      Value<String> characterId,
      Value<String> chapterId,
      Value<String> summary,
      Value<String> statusChangedFrom,
      Value<String> statusChangedTo,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CharacterChapterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterChapterLogsTable> {
  $$CharacterChapterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusChangedFrom => $composableBuilder(
    column: $table.statusChangedFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusChangedTo => $composableBuilder(
    column: $table.statusChangedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterChapterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterChapterLogsTable> {
  $$CharacterChapterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusChangedFrom => $composableBuilder(
    column: $table.statusChangedFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusChangedTo => $composableBuilder(
    column: $table.statusChangedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterChapterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterChapterLogsTable> {
  $$CharacterChapterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get statusChangedFrom => $composableBuilder(
    column: $table.statusChangedFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusChangedTo => $composableBuilder(
    column: $table.statusChangedTo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CharacterChapterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterChapterLogsTable,
          DbCharacterChapterLog,
          $$CharacterChapterLogsTableFilterComposer,
          $$CharacterChapterLogsTableOrderingComposer,
          $$CharacterChapterLogsTableAnnotationComposer,
          $$CharacterChapterLogsTableCreateCompanionBuilder,
          $$CharacterChapterLogsTableUpdateCompanionBuilder,
          (
            DbCharacterChapterLog,
            BaseReferences<
              _$AppDatabase,
              $CharacterChapterLogsTable,
              DbCharacterChapterLog
            >,
          ),
          DbCharacterChapterLog,
          PrefetchHooks Function()
        > {
  $$CharacterChapterLogsTableTableManager(
    _$AppDatabase db,
    $CharacterChapterLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterChapterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterChapterLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CharacterChapterLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> statusChangedFrom = const Value.absent(),
                Value<String> statusChangedTo = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterChapterLogsCompanion(
                id: id,
                characterId: characterId,
                chapterId: chapterId,
                summary: summary,
                statusChangedFrom: statusChangedFrom,
                statusChangedTo: statusChangedTo,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String characterId,
                required String chapterId,
                Value<String> summary = const Value.absent(),
                Value<String> statusChangedFrom = const Value.absent(),
                Value<String> statusChangedTo = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterChapterLogsCompanion.insert(
                id: id,
                characterId: characterId,
                chapterId: chapterId,
                summary: summary,
                statusChangedFrom: statusChangedFrom,
                statusChangedTo: statusChangedTo,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterChapterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterChapterLogsTable,
      DbCharacterChapterLog,
      $$CharacterChapterLogsTableFilterComposer,
      $$CharacterChapterLogsTableOrderingComposer,
      $$CharacterChapterLogsTableAnnotationComposer,
      $$CharacterChapterLogsTableCreateCompanionBuilder,
      $$CharacterChapterLogsTableUpdateCompanionBuilder,
      (
        DbCharacterChapterLog,
        BaseReferences<
          _$AppDatabase,
          $CharacterChapterLogsTable,
          DbCharacterChapterLog
        >,
      ),
      DbCharacterChapterLog,
      PrefetchHooks Function()
    >;
typedef $$WorldEntriesTableCreateCompanionBuilder =
    WorldEntriesCompanion Function({
      required String id,
      Value<String?> bookId,
      required String name,
      Value<String> description,
      Value<String?> categoryTagId,
      Value<String> flexibleJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$WorldEntriesTableUpdateCompanionBuilder =
    WorldEntriesCompanion Function({
      Value<String> id,
      Value<String?> bookId,
      Value<String> name,
      Value<String> description,
      Value<String?> categoryTagId,
      Value<String> flexibleJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WorldEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorldEntriesTable> {
  $$WorldEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryTagId => $composableBuilder(
    column: $table.categoryTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flexibleJson => $composableBuilder(
    column: $table.flexibleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorldEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorldEntriesTable> {
  $$WorldEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryTagId => $composableBuilder(
    column: $table.categoryTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flexibleJson => $composableBuilder(
    column: $table.flexibleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorldEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorldEntriesTable> {
  $$WorldEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryTagId => $composableBuilder(
    column: $table.categoryTagId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flexibleJson => $composableBuilder(
    column: $table.flexibleJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorldEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorldEntriesTable,
          DbWorldEntry,
          $$WorldEntriesTableFilterComposer,
          $$WorldEntriesTableOrderingComposer,
          $$WorldEntriesTableAnnotationComposer,
          $$WorldEntriesTableCreateCompanionBuilder,
          $$WorldEntriesTableUpdateCompanionBuilder,
          (
            DbWorldEntry,
            BaseReferences<_$AppDatabase, $WorldEntriesTable, DbWorldEntry>,
          ),
          DbWorldEntry,
          PrefetchHooks Function()
        > {
  $$WorldEntriesTableTableManager(_$AppDatabase db, $WorldEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorldEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorldEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorldEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> categoryTagId = const Value.absent(),
                Value<String> flexibleJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorldEntriesCompanion(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                categoryTagId: categoryTagId,
                flexibleJson: flexibleJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> bookId = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                Value<String?> categoryTagId = const Value.absent(),
                Value<String> flexibleJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorldEntriesCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                categoryTagId: categoryTagId,
                flexibleJson: flexibleJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorldEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorldEntriesTable,
      DbWorldEntry,
      $$WorldEntriesTableFilterComposer,
      $$WorldEntriesTableOrderingComposer,
      $$WorldEntriesTableAnnotationComposer,
      $$WorldEntriesTableCreateCompanionBuilder,
      $$WorldEntriesTableUpdateCompanionBuilder,
      (
        DbWorldEntry,
        BaseReferences<_$AppDatabase, $WorldEntriesTable, DbWorldEntry>,
      ),
      DbWorldEntry,
      PrefetchHooks Function()
    >;
typedef $$InspirationsTableCreateCompanionBuilder =
    InspirationsCompanion Function({
      required String id,
      Value<String?> bookId,
      required String level,
      required String title,
      Value<String> content,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InspirationsTableUpdateCompanionBuilder =
    InspirationsCompanion Function({
      Value<String> id,
      Value<String?> bookId,
      Value<String> level,
      Value<String> title,
      Value<String> content,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$InspirationsTableFilterComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InspirationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InspirationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InspirationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InspirationsTable,
          DbInspiration,
          $$InspirationsTableFilterComposer,
          $$InspirationsTableOrderingComposer,
          $$InspirationsTableAnnotationComposer,
          $$InspirationsTableCreateCompanionBuilder,
          $$InspirationsTableUpdateCompanionBuilder,
          (
            DbInspiration,
            BaseReferences<_$AppDatabase, $InspirationsTable, DbInspiration>,
          ),
          DbInspiration,
          PrefetchHooks Function()
        > {
  $$InspirationsTableTableManager(_$AppDatabase db, $InspirationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InspirationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InspirationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InspirationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> bookId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InspirationsCompanion(
                id: id,
                bookId: bookId,
                level: level,
                title: title,
                content: content,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> bookId = const Value.absent(),
                required String level,
                required String title,
                Value<String> content = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InspirationsCompanion.insert(
                id: id,
                bookId: bookId,
                level: level,
                title: title,
                content: content,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InspirationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InspirationsTable,
      DbInspiration,
      $$InspirationsTableFilterComposer,
      $$InspirationsTableOrderingComposer,
      $$InspirationsTableAnnotationComposer,
      $$InspirationsTableCreateCompanionBuilder,
      $$InspirationsTableUpdateCompanionBuilder,
      (
        DbInspiration,
        BaseReferences<_$AppDatabase, $InspirationsTable, DbInspiration>,
      ),
      DbInspiration,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      Value<String?> bookId,
      required String name,
      Value<String> description,
      Value<String> abilities,
      Value<bool> isUnique,
      Value<String?> currentHolderId,
      Value<String> location,
      Value<int> quantity,
      Value<String> origin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String?> bookId,
      Value<String> name,
      Value<String> description,
      Value<String> abilities,
      Value<bool> isUnique,
      Value<String?> currentHolderId,
      Value<String> location,
      Value<int> quantity,
      Value<String> origin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abilities => $composableBuilder(
    column: $table.abilities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnique => $composableBuilder(
    column: $table.isUnique,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentHolderId => $composableBuilder(
    column: $table.currentHolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilities => $composableBuilder(
    column: $table.abilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnique => $composableBuilder(
    column: $table.isUnique,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentHolderId => $composableBuilder(
    column: $table.currentHolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get abilities =>
      $composableBuilder(column: $table.abilities, builder: (column) => column);

  GeneratedColumn<bool> get isUnique =>
      $composableBuilder(column: $table.isUnique, builder: (column) => column);

  GeneratedColumn<String> get currentHolderId => $composableBuilder(
    column: $table.currentHolderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          DbItem,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (DbItem, BaseReferences<_$AppDatabase, $ItemsTable, DbItem>),
          DbItem,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> abilities = const Value.absent(),
                Value<bool> isUnique = const Value.absent(),
                Value<String?> currentHolderId = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                abilities: abilities,
                isUnique: isUnique,
                currentHolderId: currentHolderId,
                location: location,
                quantity: quantity,
                origin: origin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> bookId = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> abilities = const Value.absent(),
                Value<bool> isUnique = const Value.absent(),
                Value<String?> currentHolderId = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                abilities: abilities,
                isUnique: isUnique,
                currentHolderId: currentHolderId,
                location: location,
                quantity: quantity,
                origin: origin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      DbItem,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (DbItem, BaseReferences<_$AppDatabase, $ItemsTable, DbItem>),
      DbItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$VolumesTableTableManager get volumes =>
      $$VolumesTableTableManager(_db, _db.volumes);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$EntityLinksTableTableManager get entityLinks =>
      $$EntityLinksTableTableManager(_db, _db.entityLinks);
  $$StyleProfilesTableTableManager get styleProfiles =>
      $$StyleProfilesTableTableManager(_db, _db.styleProfiles);
  $$CategoryTagsTableTableManager get categoryTags =>
      $$CategoryTagsTableTableManager(_db, _db.categoryTags);
  $$OutlineNodesTableTableManager get outlineNodes =>
      $$OutlineNodesTableTableManager(_db, _db.outlineNodes);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$CharacterChapterLogsTableTableManager get characterChapterLogs =>
      $$CharacterChapterLogsTableTableManager(_db, _db.characterChapterLogs);
  $$WorldEntriesTableTableManager get worldEntries =>
      $$WorldEntriesTableTableManager(_db, _db.worldEntries);
  $$InspirationsTableTableManager get inspirations =>
      $$InspirationsTableTableManager(_db, _db.inspirations);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
}
