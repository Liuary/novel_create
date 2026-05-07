import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/module/knowledge_module.dart';
import '../../core/module/module_context.dart';
import '../../core/repositories/entity_link_repository.dart';
import '../../core/utils/tree_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/knowledge/tree_nav_panel.dart';
import 'outline_repository.dart';
import 'outline_node_model.dart';
import 'widgets/toggle_chip.dart';
import 'widgets/preview_node_loader.dart';
import 'widgets/outline_node_editor.dart';

class OutlineModule extends KnowledgeModule {
  static const entityTypeValue = 'outline_node';
  late ModuleContext _context;
  late OutlineRepository _repo;
  final _uuid = const Uuid();
  final ValueNotifier<String?> selectedNodeId = ValueNotifier(null);

  @override
  String get moduleId => 'outline';

  @override
  String get displayName => '大纲';

  @override
  String get entityType => entityTypeValue;

  @override
  Future<void> initialize(ModuleContext context) async {
    _context = context;
    _repo = OutlineRepository(context.database);
  }

  @override
  void dispose() {
    selectedNodeId.dispose();
    super.dispose();
  }

  @override
  Future<Map<String, dynamic>> getContextForChapter(String chapterId) async {
    String? bookId;
    try {
      final ch = await (_context.database.select(_context.database.chapters)
            ..where((t) => t.id.equals(chapterId)))
          .getSingleOrNull();
      if (ch != null) {
        final vol = await (_context.database.select(_context.database.volumes)
              ..where((t) => t.id.equals(ch.volumeId)))
            .getSingleOrNull();
        bookId = vol?.bookId;
      }
    } catch (e) { debugPrint('获取章节 bookId 失败: $e'); }

    final links = await _context.linkRepo.findByTo(
      toType: 'chapter',
      toId: chapterId,
    );
    final outlineLinks = links.where((l) => l.fromType == entityType);
    final nodes = <Map<String, dynamic>>[];
    final allNodes = await _repo.getAll(bookId: bookId);
    final nodeMap = {for (final n in allNodes) n.id: n};
    for (final link in outlineLinks) {
      final node = await _repo.getById(link.fromId);
      if (node == null) continue;
      final ancestors = TreeUtils.getAncestors(
        node.id,
        nodeMap,
        parentIdOf: (n) => n.parentId,
      ).map((id) => nodeMap[id]?.title ?? '').toList();
      nodes.add({
        'id': node.id,
        'title': node.title,
        'type': node.type,
        'status': node.status,
        'description': node.description,
        'ancestors': ancestors,
        'expectedWordCount': node.expectedWordCount,
      });
    }
    return {
      'module': moduleId,
      'nodes': nodes,
    };
  }

  @override
  Future<void> onChapterSaved(String chapterId, String content) async {}

  @override
  Future<void> onChapterCompleted(String chapterId, String content) async {
    final links = await _context.linkRepo.findByTo(
      toType: 'chapter',
      toId: chapterId,
    );
    for (final link in links) {
      if (link.fromType == entityType) {
        final node = await _repo.getById(link.fromId);
        if (node != null && node.status == 'writing') {
          await _repo.update(node.copyWith(status: 'done'));
        }
      }
    }
  }

  @override
  Widget? buildNavigationPanel(BuildContext context) {
    return _OutlineTreeNav(
      repo: _repo,
      module: this,
      selectedNotifier: selectedNodeId,
    );
  }

  @override
  Widget? buildEditor(BuildContext context) {
    return _OutlineEditorHost(
      module: this,
      repo: _repo,
      selectedNotifier: selectedNodeId,
      linkRepo: _context.linkRepo,
      contextRef: _context,
    );
  }

  @override
  Widget? buildInspector(BuildContext context, String entityId) {
    return null;
  }

  @override
  Future<void> handleLink(
      String fromEntityId, String toEntityId, String linkType) async {
    if (linkType == 'bound_to') {
      await _context.linkRepo.create(
        fromType: entityType,
        fromId: fromEntityId,
        toType: 'chapter',
        toId: toEntityId,
        linkType: linkType,
      );
    }
  }

  @override
  Future<List<SearchResult>> search(String query) async {
    final nodes = await _repo.searchByKeyword(query);
    return nodes.map((n) {
      final snippet = n.description.length > 80
          ? '${n.description.substring(0, 80)}...'
          : n.description;
      return SearchResult(
        moduleId: moduleId,
        entityId: n.id,
        title: n.title,
        snippet: snippet,
        entityType: entityType,
      );
    }).toList();
  }

  Future<void> addChild(String parentId, {String? bookId, String? title}) async {
    final sortOrder = await _repo.getNextSortOrder(parentId);
    await _repo.create(
      id: _uuid.v4(),
      bookId: bookId,
      parentId: parentId,
      title: title ?? '新节点',
      sortOrder: sortOrder,
    );
  }

  Future<void> addRoot({String? bookId, String? title}) async {
    final sortOrder = await _repo.getNextSortOrder(null);
    await _repo.create(
      id: _uuid.v4(),
      bookId: bookId,
      title: title ?? '新主线',
      type: 'main_arc',
      sortOrder: sortOrder,
    );
  }

  Future<void> renameNode(String id, String newTitle) async {
    final node = await _repo.getById(id);
    if (node != null) {
      await _repo.update(node.copyWith(title: newTitle));
    }
  }

  Future<void> deleteNode(String id) async {
    await _repo.delete(id);
  }

  Future<void> moveNode(String id, String? newParentId, int newSortOrder) async {
    await _repo.moveNode(id: id, newParentId: newParentId, newSortOrder: newSortOrder);
  }
}

class _OutlineTreeNav extends ConsumerStatefulWidget {
  final OutlineRepository repo;
  final OutlineModule module;
  final ValueNotifier<String?> selectedNotifier;

  const _OutlineTreeNav({
    required this.repo,
    required this.module,
    required this.selectedNotifier,
  });

  @override
  ConsumerState<_OutlineTreeNav> createState() => _OutlineTreeNavState();
}

class _OutlineTreeNavState extends ConsumerState<_OutlineTreeNav> {
  List<OutlineNode>? _nodes;
  String? _selectedId;
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedNotifier.value;
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    final bookId = ref.read(currentBookIdProvider);
    final nodes = bookId != null
        ? await widget.repo.getAll(bookId: bookId)
        : await widget.repo.getAllUnfiltered();
    if (!mounted) return;
    setState(() => _nodes = nodes);
  }

  void _onSelect(String id) {
    setState(() => _selectedId = id);
    widget.selectedNotifier.value = id;
  }

  @override
  Widget build(BuildContext context) {
    // 监听当前书籍变化，自动刷新大纲树
    ref.listen<String?>(currentBookIdProvider, (prev, next) {
      if (prev != next) {
        _loadNodes();
      }
    });
    if (_nodes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_nodes!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('暂无大纲节点', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(128))),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final existingNames =
                    _nodes?.map((n) => n.title).toList() ?? [];
                await widget.module.addRoot(
                    bookId: ref.read(currentBookIdProvider),
                    title: findAvailableName('新主线', existingNames));
                await _loadNodes();
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('新建主线'),
            ),
          ],
        ),
      );
    }

    final childrenMap = <String, bool>{};
    for (final n in _nodes!) {
      childrenMap[n.id] = false;
    }
    for (final n in _nodes!) {
      if (n.parentId != null) {
        childrenMap[n.parentId!] = true;
      }
    }
    final navNodes = _nodes!.map((n) => TreeNavNode(
      id: n.id,
      title: n.title,
      parentId: n.parentId,
      hasChildren: childrenMap[n.id] ?? false,
      level: _getLevel(n),
    )).toList();

    final dragMode = ref.watch(dragModeProvider);

    List<PopupMenuItem<String>> contextMenuFor(String id) => [
      PopupMenuItem(
        value: 'add_child',
        child: const Text('新建子节点'),
        onTap: () async {
          final siblings = _nodes!
              .where((n) => n.parentId == id)
              .toList();
          final existingNames =
              siblings.map((n) => n.title).toList();
          final newTitle =
              findAvailableName('新节点', existingNames);
          await widget.module.addChild(id,
              bookId: ref.read(currentBookIdProvider),
              title: newTitle);
          await _loadNodes();
        },
      ),
      PopupMenuItem(
        value: 'rename',
        child: const Text('重命名'),
        onTap: () => _showRenameDialog(id),
      ),
      if (!dragMode) ...[
        PopupMenuItem(
          value: 'move_up',
          child: const Text('上移'),
          onTap: () => _moveSibling(id, true),
        ),
        PopupMenuItem(
          value: 'move_down',
          child: const Text('下移'),
          onTap: () => _moveSibling(id, false),
        ),
      ],
      PopupMenuItem(
        value: 'delete',
        child:
            const Text('删除', style: TextStyle(color: Colors.red)),
        onTap: () async {
          await widget.module.deleteNode(id);
          if (_selectedId == id) _selectedId = null;
          await _loadNodes();
        },
      ),
    ];

    Widget treeWidget;
    if (dragMode) {
      final flatNodes = _flattenVisible();
      treeWidget = ReorderableListView(
        buildDefaultDragHandles: false,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < 0 || oldIndex >= flatNodes.length) return;
          final oldNode = flatNodes[oldIndex];
          final siblings = flatNodes
              .where((n) => n.parentId == oldNode.parentId)
              .toList();
          if (siblings.length <= 1) return;
          final firstSibIdx = flatNodes.indexOf(siblings.first);
          final lastSibIdx = flatNodes.indexOf(siblings.last) + 1;
          final clamped = newIndex.clamp(firstSibIdx, lastSibIdx);

          int effectiveTarget = clamped;
          if (effectiveTarget > oldIndex) effectiveTarget--;

          int sibIndex = 0;
          for (final s in siblings) {
            if (s.id == oldNode.id) continue;
            int pos = flatNodes.indexOf(s);
            if (pos > oldIndex) pos--;
            if (pos < effectiveTarget) {
              sibIndex++;
            } else {
              break;
            }
          }
          _applySiblingReorder(oldNode.id, sibIndex);
        },
        children: flatNodes.map((n) {
          return Container(
            key: Key(n.id),
            color: _selectedId == n.id
                ? Theme.of(context).colorScheme.primaryContainer.withAlpha(100)
                : Colors.transparent,
            padding: EdgeInsets.only(
              left: 8.0 + _getLevel(n) * 16.0,
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: flatNodes.indexOf(n),
                  child: Icon(Icons.drag_handle, size: 16,
                      color: Theme.of(context).colorScheme.outline.withAlpha(100)),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _onSelect(n.id),
                  child: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: _selectedId == n.id
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      treeWidget = TreeNavPanel(
        nodes: navNodes,
        selectedId: _selectedId,
        onSelect: _onSelect,
        contextMenuBuilder: contextMenuFor,
        expandedIds: _expandedIds,
        onToggleExpand: (id, expanded) {
          setState(() {
            if (expanded) {
              _expandedIds.add(id);
            } else {
              _expandedIds.remove(id);
            }
          });
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              const Text('大纲树', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                tooltip: '新建根节点',
                onPressed: () async {
                  final existingNames =
                      _nodes?.map((n) => n.title).toList() ?? [];
                  await widget.module.addRoot(
                      bookId: ref.read(currentBookIdProvider),
                      title: findAvailableName('新主线', existingNames));
                  await _loadNodes();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ),
        Expanded(
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.f2): () {
                if (_selectedId != null) _showRenameDialog(_selectedId!);
              },
            },
            child: Focus(
              autofocus: true,
              child: treeWidget,
            ),
          ),
        ),
      ],
    );
  }

  List<OutlineNode> _flattenVisible() {
    if (_nodes == null) return [];
    final result = <OutlineNode>[];
    final visited = <String>{};
    void addChildren(String? parentId) {
      for (final n in _nodes!) {
        if (n.parentId == parentId) {
          if (visited.add(n.id)) {
            result.add(n);
            if (_expandedIds.contains(n.id)) {
              addChildren(n.id);
            }
          }
        }
      }
    }
    addChildren(null);
    return result;
  }

  void _moveSibling(String id, bool up) {
    final nodes = _nodes;
    if (nodes == null) return;
    final node = nodes.cast<OutlineNode?>().firstWhere((n) => n!.id == id, orElse: () => null);
    if (node == null) return;
    final siblings = nodes
        .where((n) => n.parentId == node.parentId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final si = siblings.indexWhere((s) => s.id == id);
    final ti = up ? si - 1 : si + 1;
    if (ti < 0 || ti >= siblings.length) return;
    unawaited(_applySiblingReorder(id, ti));
  }

  Future<void> _applySiblingReorder(String id, int targetAfterRemove) async {
    final nodes = _nodes;
    if (nodes == null) return;
    final node = nodes.cast<OutlineNode?>().firstWhere((n) => n!.id == id, orElse: () => null);
    if (node == null) return;
    final siblings = nodes
        .where((n) => n.parentId == node.parentId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final currentSibIndex = siblings.indexWhere((s) => s.id == id);
    if (currentSibIndex < 0) return;

    final mutable = List<OutlineNode>.from(siblings);
    mutable.removeAt(currentSibIndex);
    final clamped = targetAfterRemove.clamp(0, mutable.length);
    if (clamped == currentSibIndex) return;
    mutable.insert(clamped, node);

    setState(() {
      final list = nodes;
      for (int i = 0; i < mutable.length; i++) {
        if (mutable[i].sortOrder != i) {
          final idx = list.indexWhere((n) => n.id == mutable[i].id);
          list[idx] = mutable[i].copyWith(sortOrder: i);
        }
      }
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
    // DB 写入失败时记录日志，UI 乐观更新保持响应
    try {
      await widget.repo
          .reorderSibling(id, clamped, bookId: ref.read(currentBookIdProvider));
    } catch (e) { debugPrint('大纲排序同步失败: $e'); }
  }

  /// 计算节点在大纲树中的层级（根节点 level=0）。
  int _getLevel(OutlineNode node) {
    int level = 0;
    var current = node;
    while (current.parentId != null && _nodes != null) {
      final idx = _nodes!.indexWhere((n) => n.id == current.parentId);
      if (idx < 0) break;
      level++;
      current = _nodes![idx];
    }
    return level;
  }

  void _showRenameDialog(String id) {
    final node = _nodes?.firstWhere((n) => n.id == id);
    if (node == null) return;
    final controller = TextEditingController(text: node.title);
    doRename() async {
      final nav = Navigator.of(context);
      final newTitle = controller.text.trim();
      if (newTitle.isEmpty) return;
      await widget.module.renameNode(id, newTitle);
      setState(() {
        final idx = _nodes!.indexWhere((n) => n.id == id);
        if (idx >= 0) {
          _nodes![idx] = _nodes![idx].copyWith(title: newTitle);
        }
      });
      nav.pop();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (_) => doRename(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          TextButton(
            onPressed: doRename,
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _OutlineEditorHost extends ConsumerStatefulWidget {
  final OutlineModule module;
  final OutlineRepository repo;
  final ValueNotifier<String?> selectedNotifier;
  final EntityLinkRepository linkRepo;
  final ModuleContext contextRef;

  const _OutlineEditorHost({
    required this.module,
    required this.repo,
    required this.selectedNotifier,
    required this.linkRepo,
    required this.contextRef,
  });

  @override
  ConsumerState<_OutlineEditorHost> createState() => _OutlineEditorHostState();
}

class _OutlineEditorHostState extends ConsumerState<_OutlineEditorHost> {
  bool _showPreview = false;

  @override
  Widget build(BuildContext context) {
    final currentChapterId = ref.watch(currentChapterIdProvider);

    return ValueListenableBuilder<String?>(
      valueListenable: widget.selectedNotifier,
      builder: (context, nodeId, _) {
        if (nodeId == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_tree_outlined, size: 48,
                    color: Theme.of(context).colorScheme.outline.withAlpha(80)),
                const SizedBox(height: 12),
                Text('选择大纲节点查看详情',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14)),
              ],
            ),
          );
        }

        if (_showPreview) {
          return _buildPreviewMode(nodeId);
        }
        return _buildDetailMode(nodeId, currentChapterId);
      },
    );
  }

  Widget _buildDetailMode(String nodeId, String? currentChapterId) {
    return Column(
      children: [
        _buildModeToggle(),
        Expanded(
          child: OutlineNodeEditor(
            nodeId: nodeId,
            repo: widget.repo,
            linkRepo: widget.linkRepo,
            currentChapterId: currentChapterId,
            onTitleChanged: (title) => widget.module.renameNode(nodeId, title),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewMode(String nodeId) {
    return Column(
      children: [
        _buildModeToggle(),
        Expanded(child: PreviewNodeLoader(
          repo: widget.repo,
          nodeId: nodeId,
          bookId: ref.read(currentBookIdProvider),
        )),
      ],
    );
  }

  Widget _buildModeToggle() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          ToggleChip(
            label: '详情',
            icon: Icons.edit_note,
            isActive: !_showPreview,
            onTap: () => setState(() => _showPreview = false),
          ),
          const SizedBox(width: 8),
          ToggleChip(
            label: '可视化',
            icon: Icons.account_tree,
            isActive: _showPreview,
            onTap: () => setState(() => _showPreview = true),
          ),
        ],
      ),
    );
  }
}
