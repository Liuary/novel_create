import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/database/app_database.dart' as db_impl;

class ChapterRepository {
  final AppDatabase _db;

  ChapterRepository(this._db);

  Future<DbChapter?> findById(String id) =>
      (_db.select(_db.chapters)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<DbChapter>> findByVolumeId(String volumeId) =>
      (_db.select(_db.chapters)..where((t) => t.volumeId.equals(volumeId)))
          .get();

  Future<void> upsert({
    required String id,
    required String volumeId,
    required String name,
    String? filePath,
    int sortOrder = 0,
    String summary = '',
    String status = 'draft',
    int wordCount = 0,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await _db.into(_db.chapters).insertOnConflictUpdate(
          db_impl.ChaptersCompanion.insert(
            id: id,
            volumeId: volumeId,
            name: name,
            filePath: Value(filePath),
            sortOrder: Value(sortOrder),
            summary: Value(summary),
            status: Value(status),
            wordCount: Value(wordCount),
            createdAt: Value(createdAt),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.chapters)..where((t) => t.id.equals(id))).go();

  Future<void> deleteByVolumeId(String volumeId) =>
      (_db.delete(_db.chapters)..where((t) => t.volumeId.equals(volumeId)))
          .go();
}
