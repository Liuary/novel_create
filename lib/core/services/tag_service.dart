import 'package:drift/drift.dart';
import '../database/app_database.dart';

class TagService {
  final AppDatabase _db;

  TagService(this._db);

  Future<List<DbCategoryTag>> getByModule(String moduleId) =>
      (_db.select(_db.categoryTags)
            ..where((t) => t.moduleId.equals(moduleId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<List<DbCategoryTag>> getGlobal() => getByModule('');

  Future<List<DbCategoryTag>> getRoots({String? moduleId}) {
    if (moduleId != null) {
      return (_db.select(_db.categoryTags)
            ..where((t) => t.moduleId.equals(moduleId))
            ..where((t) => t.parentId.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
    }
    return (_db.select(_db.categoryTags)
          ..where((t) => t.parentId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<DbCategoryTag>> getChildren(String parentId) =>
      (_db.select(_db.categoryTags)
            ..where((t) => t.parentId.equals(parentId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<DbCategoryTag?> getById(String id) =>
      (_db.select(_db.categoryTags)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<DbCategoryTag> create({
    required String id,
    required String name,
    String? parentId,
    String moduleId = '',
  }) async {
    await _db.into(_db.categoryTags).insert(
          CategoryTagsCompanion.insert(
            id: id,
            name: name,
            parentId: Value(parentId),
            moduleId: Value(moduleId),
          ),
        );
    return (await getById(id))!;
  }

  Future<void> update(DbCategoryTag tag) async {
    await (_db.update(_db.categoryTags)..where((t) => t.id.equals(tag.id)))
        .write(tag);
  }

  Future<void> delete(String id) async {
    final children = await getChildren(id);
    for (final child in children) {
      await delete(child.id);
    }
    await (_db.delete(_db.categoryTags)..where((t) => t.id.equals(id))).go();
  }

  Future<List<DbCategoryTag>> getAncestors(String id) async {
    final ancestors = <DbCategoryTag>[];
    var current = await getById(id);
    while (current != null && current.parentId != null) {
      final parent = await getById(current.parentId!);
      if (parent != null) {
        ancestors.insert(0, parent);
        current = parent;
      } else {
        break;
      }
    }
    return ancestors;
  }

  Future<List<DbCategoryTag>> getAll({String? moduleId}) {
    if (moduleId != null) {
      return (_db.select(_db.categoryTags)
            ..where((t) => t.moduleId.equals(moduleId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
    }
    return (_db.select(_db.categoryTags)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }
}
