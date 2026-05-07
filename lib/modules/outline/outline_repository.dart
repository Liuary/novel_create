import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import 'outline_node_model.dart';

class OutlineRepository {
  final AppDatabase _db;

  OutlineRepository(this._db);

  Future<OutlineNode> create({
    required String id,
    String? bookId,
    String? parentId,
    required String title,
    String description = '',
    int expectedWordCount = 0,
    String type = 'free',
    int sortOrder = 0,
    String status = 'planning',
  }) async {
    final now = DateTime.now();
    await _db.into(_db.outlineNodes).insert(
          OutlineNodesCompanion.insert(
            id: id,
            title: title,
            bookId: Value(bookId),
            parentId: Value(parentId),
            description: Value(description),
            expectedWordCount: Value(expectedWordCount),
            type: Value(type),
            sortOrder: Value(sortOrder),
            status: Value(status),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    final db = await getById(id);
    if (db == null) throw StateError('节点创建后读取失败: $id');
    return db;
  }

  Future<OutlineNode?> getById(String id) async {
    final db = await (_db.select(_db.outlineNodes)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return db == null ? null : OutlineNode.fromDb(db);
  }

  /// 获取所有大纲节点。bookId 为 null 时返回全部节点（不按 bookId 过滤）。
  Future<List<OutlineNode>> getAll({String? bookId}) {
    final q = _db.select(_db.outlineNodes);
    if (bookId != null) {
      q.where((t) => t.bookId.equals(bookId));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return q.get().then((rows) => rows.map(OutlineNode.fromDb).toList());
  }

  Future<List<OutlineNode>> getRoots({String? bookId}) {
    final q = _db.select(_db.outlineNodes);
    q.where((t) => t.parentId.isNull());
    if (bookId != null) {
      q.where((t) => t.bookId.equals(bookId));
    } else {
      q.where((t) => t.bookId.isNull());
    }
    q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return q.get().then((rows) => rows.map(OutlineNode.fromDb).toList());
  }

  Future<List<OutlineNode>> getChildren(String parentId, {String? bookId}) {
    final q = _db.select(_db.outlineNodes);
    q.where((t) => t.parentId.equals(parentId));
    if (bookId != null) {
      q.where((t) => t.bookId.equals(bookId));
    } else {
      q.where((t) => t.bookId.isNull());
    }
    q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return q.get().then((rows) => rows.map(OutlineNode.fromDb).toList());
  }

  Future<void> update(OutlineNode node) async {
    await (_db.update(_db.outlineNodes)..where((t) => t.id.equals(node.id)))
        .write(node.toCompanion());
  }

  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final children = await getChildren(id);
      for (final child in children) {
        await delete(child.id);
      }
      await (_db.delete(_db.entityLinks)
            ..where((t) => t.fromType.equals('outline_node'))
            ..where((t) => t.fromId.equals(id)))
          .go();
      await (_db.delete(_db.outlineNodes)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> moveNode({
    required String id,
    required String? newParentId,
    required int newSortOrder,
  }) async {
    final node = await getById(id);
    if (node == null) return;
    await update(node.copyWith(parentId: newParentId, sortOrder: newSortOrder));
  }

  Future<void> reorderSibling(String id, int newIndex, {String? bookId}) async {
    final node = await getById(id);
    if (node == null) return;
    final siblings = node.parentId != null
        ? await getChildren(node.parentId!, bookId: bookId)
        : await getRoots(bookId: bookId);
    if (siblings.length <= 1) return;
    final currentIndex = siblings.indexWhere((s) => s.id == id);
    if (currentIndex < 0 || newIndex == currentIndex) return;
    final clampedIndex = newIndex.clamp(0, siblings.length - 1);
    if (clampedIndex == currentIndex) return;

    final mutable = List<OutlineNode>.from(siblings);
    mutable.removeAt(currentIndex);
    mutable.insert(clampedIndex, node);
    await _db.transaction(() async {
      for (int i = 0; i < mutable.length; i++) {
        if (mutable[i].sortOrder != i) {
          await update(mutable[i].copyWith(sortOrder: i));
        }
      }
    });
  }

  Future<List<OutlineNode>> searchByKeyword(String query) {
    final escaped = query.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
    final likeQuery = '%$escaped%';
    return (_db.select(_db.outlineNodes)
          ..where((t) =>
              t.title.like(likeQuery) | t.description.like(likeQuery)))
        .get()
        .then((rows) => rows.map(OutlineNode.fromDb).toList());
  }

  Future<int> getNextSortOrder(String? parentId, {String? bookId}) async {
    final children = parentId != null
        ? await getChildren(parentId, bookId: bookId)
        : await getRoots(bookId: bookId);
    if (children.isEmpty) return 0;
    return children.last.sortOrder + 1;
  }

  Future<List<OutlineNode>> getAllUnfiltered() {
    final q = _db.select(_db.outlineNodes);
    q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return q.get().then((rows) => rows.map(OutlineNode.fromDb).toList());
  }
}
