import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/database/app_database.dart' as db_impl;

class EntityLinkRepository {
  final AppDatabase _db;

  EntityLinkRepository(this._db);

  Future<DbEntityLink> create({
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
    required String linkType,
    String metadata = '{}',
  }) async {
    final id = await _db.into(_db.entityLinks).insert(
          db_impl.EntityLinksCompanion.insert(
            fromType: fromType,
            fromId: fromId,
            toType: toType,
            toId: toId,
            linkType: linkType,
            metadata: Value(metadata),
          ),
        );
    return (await (_db.select(_db.entityLinks)
          ..where((t) => t.id.equals(id)))
        .getSingle());
  }

  Future<List<DbEntityLink>> findByFrom({
    required String fromType,
    required String fromId,
  }) {
    return (_db.select(_db.entityLinks)
          ..where((t) => t.fromType.equals(fromType))
          ..where((t) => t.fromId.equals(fromId)))
        .get();
  }

  Future<List<DbEntityLink>> findByTo({
    required String toType,
    required String toId,
  }) {
    return (_db.select(_db.entityLinks)
          ..where((t) => t.toType.equals(toType))
          ..where((t) => t.toId.equals(toId)))
        .get();
  }

  Future<List<DbEntityLink>> findByLinkType(String linkType) =>
      (_db.select(_db.entityLinks)
            ..where((t) => t.linkType.equals(linkType)))
          .get();

  Future<void> deleteByFrom({
    required String fromType,
    required String fromId,
  }) {
    return (_db.delete(_db.entityLinks)
          ..where((t) => t.fromType.equals(fromType))
          ..where((t) => t.fromId.equals(fromId)))
        .go();
  }

  Future<void> deleteById(int id) =>
      (_db.delete(_db.entityLinks)..where((t) => t.id.equals(id))).go();
}
