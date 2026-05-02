class TreeNode<T> {
  final T data;
  final List<TreeNode<T>> children;
  final String? parentId;
  final String id;
  final int sortOrder;

  const TreeNode({
    required this.data,
    this.children = const [],
    this.parentId,
    required this.id,
    this.sortOrder = 0,
  });
}

class TreeUtils {
  static Map<String?, List<T>> groupByParent<T>(
    Iterable<T> items, {
    required String Function(T) idOf,
    required String? Function(T) parentIdOf,
    required int Function(T) sortOrderOf,
  }) {
    final map = <String?, List<T>>{};
    for (final item in items) {
      final parentId = parentIdOf(item);
      map.putIfAbsent(parentId, () => []).add(item);
    }
    for (final list in map.values) {
      list.sort((a, b) => sortOrderOf(a).compareTo(sortOrderOf(b)));
    }
    return map;
  }

  static List<String> getAncestors<T>(
    String nodeId,
    Map<String, T> items, {
    required String? Function(T) parentIdOf,
  }) {
    final ancestors = <String>[];
    var currentId = nodeId;
    while (true) {
      final item = items[currentId];
      if (item == null) break;
      final parentId = parentIdOf(item);
      if (parentId == null) break;
      ancestors.insert(0, parentId);
      currentId = parentId;
    }
    return ancestors;
  }

  static Set<String> getDescendants<T>(
    String nodeId,
    Map<String?, List<T>> grouped, {
    required String Function(T) idOf,
  }) {
    final descendants = <String>{};
    void traverse(String id) {
      final children = grouped[id] ?? [];
      for (final child in children) {
        final childId = idOf(child);
        descendants.add(childId);
        traverse(childId);
      }
    }
    traverse(nodeId);
    return descendants;
  }

  static List<T> flattenTree<T>(
    String? rootId,
    Map<String?, List<T>> grouped, {
    required String Function(T) idOf,
    required int depth,
  }) {
    final result = <T>[];
    void traverse(String? parentId, int currentDepth) {
      final children = grouped[parentId] ?? [];
      for (final child in children) {
        result.add(child);
        traverse(idOf(child), currentDepth + 1);
      }
    }
    traverse(rootId, depth);
    return result;
  }
}
