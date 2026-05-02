import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class OutlineNode {
  final String id;
  final String? bookId;
  final String? parentId;
  final String title;
  final String description;
  final int expectedWordCount;
  final String type; // main_arc / sub_arc / scene / free
  final int sortOrder;
  final String status; // planning / writing / done
  final DateTime createdAt;
  final DateTime updatedAt;

  const OutlineNode({
    required this.id,
    this.bookId,
    this.parentId,
    required this.title,
    this.description = '',
    this.expectedWordCount = 0,
    this.type = 'free',
    this.sortOrder = 0,
    this.status = 'planning',
    required this.createdAt,
    required this.updatedAt,
  });

  factory OutlineNode.fromDb(DbOutlineNode db) => OutlineNode(
        id: db.id,
        bookId: db.bookId,
        parentId: db.parentId,
        title: db.title,
        description: db.description,
        expectedWordCount: db.expectedWordCount,
        type: db.type,
        sortOrder: db.sortOrder,
        status: db.status,
        createdAt: db.createdAt,
        updatedAt: db.updatedAt,
      );

  OutlineNodesCompanion toCompanion() => OutlineNodesCompanion(
        id: Value(id),
        bookId: Value(bookId),
        parentId: Value(parentId),
        title: Value(title),
        description: Value(description),
        expectedWordCount: Value(expectedWordCount),
        type: Value(type),
        sortOrder: Value(sortOrder),
        status: Value(status),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );

  OutlineNode copyWith({
    String? title,
    String? description,
    int? expectedWordCount,
    String? type,
    int? sortOrder,
    String? status,
    String? parentId,
  }) =>
      OutlineNode(
        id: id,
        bookId: bookId,
        parentId: parentId ?? this.parentId,
        title: title ?? this.title,
        description: description ?? this.description,
        expectedWordCount: expectedWordCount ?? this.expectedWordCount,
        type: type ?? this.type,
        sortOrder: sortOrder ?? this.sortOrder,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
