import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import 'character_model.dart';

class CharacterRepository {
  final AppDatabase _db;

  CharacterRepository(this._db);

  Future<Character> create(CharactersCompanion entry) async {
    await _db.into(_db.characters).insert(entry);
    final row = await (_db.select(_db.characters)
          ..where((t) => t.id.equals(entry.id.value)))
        .getSingle();
    return Character.fromDb(row);
  }

  Future<void> update(Character character) async {
    await (_db.update(_db.characters)..where((t) => t.id.equals(character.id)))
        .write(character.toCompanion());
  }

  Future<Character?> getById(String id) async {
    final db = await (_db.select(_db.characters)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return db == null ? null : Character.fromDb(db);
  }

  Future<Map<String, Character>> getByIds(Set<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (_db.select(_db.characters)
          ..where((t) => t.id.isIn(ids)))
        .get();
    return {
      for (final row in rows) row.id: Character.fromDb(row),
    };
  }

  Future<List<Character>> getAll({String? bookId}) {
    final q = _db.select(_db.characters);
    if (bookId != null) {
      q.where((t) => t.bookId.equals(bookId));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return q.get().then((rows) => rows.map(Character.fromDb).toList());
  }

  Future<List<Character>> search(String query) {
    final escaped = query.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
    return (_db.select(_db.characters)..where((t) =>
            t.name.like('%$escaped%') | t.aliases.like('%$escaped%') |
            t.personalityTags.like('%$escaped%') | t.background.like('%$escaped%')))
        .get()
        .then((rows) => rows.map(Character.fromDb).toList());
  }

  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.characterChapterLogs)
            ..where((t) => t.characterId.equals(id)))
          .go();
      await (_db.delete(_db.entityLinks)
            ..where((t) => t.fromType.equals('character'))
            ..where((t) => t.fromId.equals(id)))
          .go();
      await (_db.delete(_db.characters)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<ChapterLog> addLog(CharacterChapterLogsCompanion entry) async {
    await _db.into(_db.characterChapterLogs).insert(entry);
    final row = await (_db.select(_db.characterChapterLogs)
          ..where((t) => t.id.equals(entry.id.value)))
        .getSingle();
    return ChapterLog.fromDb(row);
  }

  Future<List<ChapterLog>> getLogs(String characterId) {
    return (_db.select(_db.characterChapterLogs)
          ..where((t) => t.characterId.equals(characterId))
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)]))
        .get()
        .then((rows) => rows.map(ChapterLog.fromDb).toList());
  }

  Future<List<ChapterLog>> getLogsByChapter(String chapterId) {
    return (_db.select(_db.characterChapterLogs)
          ..where((t) => t.chapterId.equals(chapterId)))
        .get()
        .then((rows) => rows.map(ChapterLog.fromDb).toList());
  }

  Future<void> deleteLog(String id) async {
    await (_db.delete(_db.characterChapterLogs)..where((t) => t.id.equals(id))).go();
  }
}
