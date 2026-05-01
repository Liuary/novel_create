import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('DbBook')
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get path => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbVolume')
class Volumes extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbChapter')
class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get volumeId => text()();
  TextColumn get name => text()();
  TextColumn get filePath => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbEntityLink')
class EntityLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fromType => text()();
  TextColumn get fromId => text()();
  TextColumn get toType => text()();
  TextColumn get toId => text()();
  TextColumn get linkType => text()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DbStyleProfile')
class StyleProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get systemPromptTemplate => text().withDefault(const Constant(''))();
  TextColumn get exampleText => text().withDefault(const Constant(''))();
  TextColumn get parametersJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Books, Volumes, Chapters, EntityLinks, StyleProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {},
      );
}
