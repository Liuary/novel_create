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

@DataClassName('DbCategoryTag')
class CategoryTags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get moduleId => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbOutlineNode')
class OutlineNodes extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get expectedWordCount => integer().withDefault(const Constant(0))();
  TextColumn get type => text().withDefault(const Constant('free'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('planning'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbCharacter')
class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get aliases => text().withDefault(const Constant(''))();
  TextColumn get personalityTags => text().withDefault(const Constant(''))();
  TextColumn get appearance => text().withDefault(const Constant(''))();
  TextColumn get background => text().withDefault(const Constant(''))();
  TextColumn get currentStatus => text().withDefault(const Constant(''))();
  TextColumn get locationId => text().nullable()();
  BoolColumn get isDead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbCharacterChapterLog')
class CharacterChapterLogs extends Table {
  TextColumn get id => text()();
  TextColumn get characterId => text()();
  TextColumn get chapterId => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get statusChangedFrom => text().withDefault(const Constant(''))();
  TextColumn get statusChangedTo => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbWorldEntry')
class WorldEntries extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get categoryTagId => text().nullable()();
  TextColumn get flexibleJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbInspiration')
class Inspirations extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get level => text()();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('user'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DbItem')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get abilities => text().withDefault(const Constant(''))();
  BoolColumn get isUnique => boolean().withDefault(const Constant(false))();
  TextColumn get currentHolderId => text().nullable()();
  TextColumn get location => text().withDefault(const Constant(''))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get origin => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Books, Volumes, Chapters, EntityLinks, StyleProfiles,
  CategoryTags, OutlineNodes, Characters, CharacterChapterLogs,
  WorldEntries, Inspirations, Items,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(categoryTags);
            await m.createTable(outlineNodes);
            await m.createTable(characters);
            await m.createTable(characterChapterLogs);
            await m.createTable(worldEntries);
            await m.createTable(inspirations);
            await m.createTable(items);
          }
        },
      );
}
