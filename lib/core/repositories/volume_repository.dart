import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/database/app_database.dart' as db_impl;

class VolumeRepository {
  final AppDatabase _db;

  VolumeRepository(this._db);

  Future<DbVolume?> findById(String id) =>
      (_db.select(_db.volumes)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<DbVolume>> findByBookId(String bookId) =>
      (_db.select(_db.volumes)..where((t) => t.bookId.equals(bookId))).get();

  Future<void> upsert({
    required String id,
    required String bookId,
    required String name,
    int sortOrder = 0,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await _db.into(_db.volumes).insertOnConflictUpdate(
          db_impl.VolumesCompanion.insert(
            id: id,
            bookId: bookId,
            name: name,
            sortOrder: Value(sortOrder),
            createdAt: Value(createdAt),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.volumes)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> deleteByBookId(String bookId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.volumes)..where((t) => t.bookId.equals(bookId))).go();
    });
  }
}
