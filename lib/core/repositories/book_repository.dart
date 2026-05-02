import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/database/app_database.dart' as db_impl;

class BookRepository {
  final AppDatabase _db;

  BookRepository(this._db);

  Future<DbBook?> findById(String id) =>
      (_db.select(_db.books)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<DbBook>> all() => _db.select(_db.books).get();

  Future<void> upsert({
    required String id,
    required String name,
    String? path,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await _db.into(_db.books).insertOnConflictUpdate(
          db_impl.BooksCompanion.insert(
            id: id,
            name: name,
            path: Value(path),
            createdAt: Value(createdAt),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.books)..where((t) => t.id.equals(id))).go();

  Future<int> count() async {
    final result = await _db.customSelect('SELECT COUNT(*) AS cnt FROM books').getSingle();
    return result.read<int>('cnt');
  }
}
