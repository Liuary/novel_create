import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../models/volume.dart';
import '../models/chapter.dart';
import '../providers/app_providers.dart';
import '../services/storage_service.dart';
import 'search_util.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  List<ChapterSearchResult>? _searchResults;
  String _lastQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String bookId, List<Volume> volumes,
      String? currentChapterId, String? currentVolumeId) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _lastQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final storage = StorageService.instance;
    final results = <ChapterSearchResult>[];
    final chapterPositions = <String, int>{};
    int positionCounter = 0;

    // 建立章节的位置索引
    int? currentPos;
    for (final vol in volumes) {
      for (final cid in vol.chapterIds) {
        chapterPositions[cid] = positionCounter;
        if (cid == currentChapterId) currentPos = positionCounter;
        positionCounter++;
      }
    }

    for (final vol in volumes) {
      for (final cid in vol.chapterIds) {
        final chapter =
            await storage.loadChapter(bookId, vol.id, cid);
        if (chapter == null) continue;

        final distanceFromCurrent = currentPos != null
            ? (chapterPositions[cid]! - currentPos).abs()
            : chapterPositions[cid]!;
        final queryLower = query.toLowerCase();

        // 章节名匹配优先
        if (chapter.title.toLowerCase().contains(queryLower)) {
          results.add(ChapterSearchResult(
            bookId: bookId,
            volumeId: vol.id,
            volumeName: vol.title,
            chapterId: cid,
            chapterName: chapter.title,
            content: chapter.content,
            matchPosition: 0,
            proximityIndex: distanceFromCurrent,
            isTitleMatch: true,
          ));
          continue;
        }

        // 正文匹配（每章仅取第一个匹配）
        if (chapter.content.isNotEmpty) {
          final contentMatches = findAllMatches(chapter.content, query);
          if (contentMatches.isNotEmpty) {
            results.add(ChapterSearchResult(
              bookId: bookId,
              volumeId: vol.id,
              volumeName: vol.title,
              chapterId: cid,
              chapterName: chapter.title,
              content: chapter.content,
              matchPosition: contentMatches.first.start,
              proximityIndex: distanceFromCurrent,
            ));
          }
        }
      }
    }

    // 排序：优先按章节距离，相同章节按匹配位置
    results.sort((a, b) {
      final distDiff = a.proximityIndex.compareTo(b.proximityIndex);
      if (distDiff != 0) return distDiff;
      if (a.chapterId != b.chapterId) return 0;
      return a.matchPosition.compareTo(b.matchPosition);
    });

    if (mounted) {
      setState(() {
        _searchResults = results;
        _lastQuery = query;
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = null;
      _lastQuery = '';
    });
  }

  void _openChapterFromSearch(ChapterSearchResult result,
      {bool jumpToMatch = false}) {
    final isSameChapter = ref.read(currentChapterIdProvider) == result.chapterId;
    ref.read(currentVolumeIdProvider.notifier).state = result.volumeId;
    ref.read(currentChapterIdProvider.notifier).state = result.chapterId;

    if (jumpToMatch || isSameChapter) {
      // 同章切换或需跳转定位时强制重新激活内联搜索
      ref.read(autoInlineSearchProvider.notifier).state = null;
      Future.microtask(() {
        if (mounted) {
          ref.read(autoInlineSearchProvider.notifier).state = _lastQuery;
        }
      });
    } else {
      ref.read(autoInlineSearchProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bookListProvider);
    final currentBookId = ref.watch(currentBookIdProvider);
    final currentChapterId = ref.watch(currentChapterIdProvider);
    final currentVolumeId = ref.watch(currentVolumeIdProvider);
    final selectedBook = booksAsync.whenOrNull(data: (books) {
      if (currentBookId == null) return null;
      try {
        return books.firstWhere((b) => b.id == currentBookId);
      } catch (_) {
        return null;
      }
    });

    final tab = ref.watch(sidebarTabProvider);
    final theme = Theme.of(context);

    return Container(
      width: 280,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          if (tab == 'tree')
            _buildHeader(context, ref, selectedBook, currentBookId),
          Expanded(
            child: _searchResults != null && _lastQuery.isNotEmpty
                ? _buildSearchResultList(theme, currentBookId,
                    currentVolumeId, currentChapterId)
                : tab == 'tree'
                    ? (selectedBook != null
                        ? _BookVolumeChapterTree(
                            book: selectedBook,
                            onSearch: (vols) => _performSearch(
                                selectedBook.id, vols, currentChapterId,
                                currentVolumeId),
                          )
                        : _BookListView(booksAsync: booksAsync))
                    : _KnowledgeBasePanel(currentBookId: currentBookId),
          ),
          if (tab == 'tree' && selectedBook != null)
            _buildSearchBar(theme, selectedBook),
          _buildTabBar(context, ref, tab, theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, Book selectedBook) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                hintText: '搜索章节内容...',
                hintStyle: TextStyle(
                    fontSize: 12, color: theme.colorScheme.outline),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onSubmitted: (_) => _triggerSearch(selectedBook),
            ),
          ),
          const SizedBox(width: 4),
          _isSearching
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _triggerSearch(selectedBook),
                ),
        ],
      ),
    );
  }

  void _triggerSearch(Book selectedBook) {
    final storage = ref.read(storageServiceProvider);
    final bookId = selectedBook.id;
    storage.loadVolumes(bookId, selectedBook.volumeIds).then((vols) {
      _performSearch(
          bookId, vols, ref.read(currentChapterIdProvider),
          ref.read(currentVolumeIdProvider));
    });
  }

  Widget _buildSearchResultList(ThemeData theme, String? currentBookId,
      String? currentVolumeId, String? currentChapterId) {
    if (_searchResults!.isEmpty) {
      return Center(
        child: Text('未查找到相关内容',
            style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
      );
    }

    return ListView.builder(
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final r = _searchResults![index];
        final isCurrentChapter = r.chapterId == currentChapterId;
        final snippet = getSnippet(
            r.content, r.matchPosition, r.matchPosition + _lastQuery.length);

        return Container(
          decoration: isCurrentChapter
              ? BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: theme.colorScheme.primary, width: 3)))
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openChapterFromSearch(r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: buildHighlightedText(
                    '${r.volumeName} / ${r.chapterName}',
                    _lastQuery,
                    baseStyle: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                ),
              ),
              if (r.content.toLowerCase().contains(_lastQuery.toLowerCase()))
                InkWell(
                  onTap: () => _openChapterFromSearch(r, jumpToMatch: true),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, bottom: 6),
                    child: buildHighlightedText(
                      snippet,
                      _lastQuery,
                      baseStyle: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 2,
                    ),
                  ),
                ),
              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(
      BuildContext context, WidgetRef ref, String currentTab, ThemeData theme) {
    final dragMode = ref.watch(dragModeProvider);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(sidebarTabProvider.notifier).state = 'tree',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                color: currentTab == 'tree'
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                child: Text(
                  '内容树',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        currentTab == 'tree' ? FontWeight.w600 : null,
                    color: currentTab == 'tree'
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, color: theme.dividerColor, height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(sidebarTabProvider.notifier).state = 'knowledge',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                color: currentTab == 'knowledge'
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                child: Text(
                  '知识库',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        currentTab == 'knowledge' ? FontWeight.w600 : null,
                    color: currentTab == 'knowledge'
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, color: theme.dividerColor, height: 24),
          GestureDetector(
            onTap: () =>
                ref.read(dragModeProvider.notifier).state = !dragMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Icon(
                Icons.reorder,
                size: 18,
                color: dragMode
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withAlpha(80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Book? selectedBook,
    String? currentBookId,
  ) {
    final theme = Theme.of(context);
    if (selectedBook != null) {
      return GestureDetector(
        onTap: () {
          ref.read(currentBookIdProvider.notifier).state = null;
          ref.read(currentVolumeIdProvider.notifier).state = null;
          ref.read(currentChapterIdProvider.notifier).state = null;
          _clearSearch();
        },
        onSecondaryTapDown: (details) {
          _showBookContextMenu(
              context, ref, selectedBook, details.globalPosition);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.arrow_back,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedBook.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: '新建卷',
                onPressed: () =>
                    _showCreateVolumeDialog(context, ref, selectedBook.id),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text(
            '作品列表',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: '新建书籍',
            onPressed: () => _showCreateBookDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showBookContextMenu(
    BuildContext context,
    WidgetRef ref,
    Book book,
    Offset position,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          child: const Row(children: [
            Icon(Icons.edit, size: 18),
            SizedBox(width: 8),
            Text('重命名')
          ]),
          onTap: () => _showRenameBookDialog(context, ref, book),
        ),
        PopupMenuItem(
          child: const Row(children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text('新建卷')
          ]),
          onTap: () => _showCreateVolumeDialog(context, ref, book.id),
        ),
        PopupMenuItem(
          child: const Row(children: [
            Icon(Icons.delete, size: 18),
            SizedBox(width: 8),
            Text('删除')
          ]),
          onTap: () =>
              _showDeleteConfirm(context, ref, '书籍 ${book.title}', () async {
            await ref.read(bookListProvider.notifier).deleteBook(book.id);
            if (ref.read(currentBookIdProvider) == book.id) {
              ref.read(currentBookIdProvider.notifier).state = null;
            }
          }),
        ),
      ],
    );
  }

  void _showRenameBookDialog(BuildContext context, WidgetRef ref, Book book) {
    _showTextInputDialog(
      context: context,
      title: '重命名书籍',
      initialValue: book.title,
      onConfirm: (newTitle) {
        ref.read(bookListProvider.notifier).renameBook(book.id, newTitle);
      },
    );
  }

  void _showCreateBookDialog(BuildContext context, WidgetRef ref) {
    _showTextInputDialog(
      context: context,
      title: '新建书籍',
      hintText: '书籍名称',
      onConfirm: (title) async {
        final notifier = ref.read(bookListProvider.notifier);
        final book = await notifier.createBook(title);
        ref.read(currentBookIdProvider.notifier).state = book.id;
        ref.read(currentVolumeIdProvider.notifier).state = null;
        ref.read(currentChapterIdProvider.notifier).state = null;
      },
    );
  }

  void _showCreateVolumeDialog(
      BuildContext context, WidgetRef ref, String bookId) {
    final storage = ref.read(storageServiceProvider);
    final controller = TextEditingController();
    Future.microtask(() async {
      final book = await storage.loadBook(bookId);
      if (book == null || controller.text.isNotEmpty) return;
      final volumes = await storage.loadVolumes(bookId, book.volumeIds);
      final existingNames = volumes.map((v) => v.title).toList();
      controller.text = findAvailableName('新卷', existingNames);
    });
    _showTextInputDialog(
      context: context,
      title: '新建卷',
      hintText: '卷名称',
      controller: controller,
      onConfirm: (title) async {
        await ref.read(bookListProvider.notifier).createVolume(bookId, title);
      },
    );
  }

  void _showTextInputDialog({
    required BuildContext context,
    required String title,
    String? hintText,
    String initialValue = '',
    TextEditingController? controller,
    required FutureOr<void> Function(String) onConfirm,
  }) {
    final ctrl = controller ?? TextEditingController(text: initialValue);
    doConfirm() async {
      final text = ctrl.text.trim();
      if (text.isNotEmpty) {
        await onConfirm(text);
        if (context.mounted) Navigator.pop(context);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: hintText),
          onSubmitted: (_) => doConfirm(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: doConfirm,
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, String label,
      Future<void> Function() onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 $label 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await onDelete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ==================== 知识库面板 ====================

class _KnowledgeBasePanel extends ConsumerStatefulWidget {
  final String? currentBookId;
  const _KnowledgeBasePanel({required this.currentBookId});

  @override
  ConsumerState<_KnowledgeBasePanel> createState() =>
      _KnowledgeBasePanelState();
}

class _KnowledgeBasePanelState extends ConsumerState<_KnowledgeBasePanel> {
  String? _activeModuleId;

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(moduleRegistryProvider);
    final modules = registry.modules;

    if (_activeModuleId != null) {
      final module = registry.getById(_activeModuleId!);
      if (module != null) {
        final nav = module.buildNavigationPanel(context);
        if (nav != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeModuleId = null);
                        ref.read(activeKnowledgeModuleIdProvider.notifier).state = null;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 16,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('返回',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(module.displayName,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: nav),
            ],
          );
        }
      }
    }

    if (modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books_outlined, size: 40,
                color: Theme.of(context).colorScheme.outline.withAlpha(80)),
            const SizedBox(height: 8),
            Text('暂无知识库模块',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12)),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text('知识库模块',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary)),
        ),
        const Divider(height: 1),
        ...modules.map((m) => ListTile(
              dense: true,
              leading: Icon(_moduleIcon(m.moduleId), size: 20),
              title: Text(m.displayName, style: const TextStyle(fontSize: 13)),
              onTap: () {
                setState(() => _activeModuleId = m.moduleId);
                ref.read(activeKnowledgeModuleIdProvider.notifier).state = m.moduleId;
              },
            )),
        Divider(height: 1, color: theme.dividerColor),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.currentBookId != null
                ? '当前书籍的私有知识库'
                : '请先选择书籍以使用私有知识库',
            style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.outline.withAlpha(128)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  IconData _moduleIcon(String moduleId) {
    switch (moduleId) {
      case 'outline':
        return Icons.account_tree_outlined;
      case 'character':
        return Icons.person_outline;
      case 'world':
        return Icons.public_outlined;
      case 'inspiration':
        return Icons.lightbulb_outline;
      case 'item':
        return Icons.category_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }
}

// ==================== 书籍列表视图 ====================

class _BookListView extends ConsumerWidget {
  final AsyncValue<List<Book>> booksAsync;
  const _BookListView({required this.booksAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('加载失败: $err')),
      data: (books) {
        if (books.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无书籍，点击 + 创建',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _TreeItem(
              depth: 0,
              icon: Icons.menu_book,
              label: book.title,
              isSelected: false,
              onTap: () {
                ref.read(currentBookIdProvider.notifier).state = book.id;
                ref.read(currentVolumeIdProvider.notifier).state = null;
                ref.read(currentChapterIdProvider.notifier).state = null;
              },
              menuItems: [
                _MenuItem('重命名', Icons.edit, () {
                  _showRenameDialog(context, ref, book);
                }),
                _MenuItem('删除', Icons.delete, () {
                  _showDeleteConfirmDialog(context, ref, book);
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Book book) {
    final controller = TextEditingController(text: book.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名书籍'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '新名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                ref
                    .read(bookListProvider.notifier)
                    .renameBook(book.id, newTitle);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context, WidgetRef ref, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除书籍 ${book.title} 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(bookListProvider.notifier).deleteBook(book.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ==================== 卷和章树 ====================

void _showRenameDialog(
    BuildContext context, String title, String initialValue,
    ValueChanged<String> onConfirm) {
  final controller = TextEditingController(text: initialValue);
  doConfirm() {
    final text = controller.text.trim();
    if (text.isNotEmpty) onConfirm(text);
  }
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: '新名称'),
        onSubmitted: (_) => doConfirm(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: doConfirm, child: const Text('确定')),
      ],
    ),
  );
}

class _BookVolumeChapterTree extends ConsumerStatefulWidget {
  final Book book;
  final void Function(List<Volume>) onSearch;
  const _BookVolumeChapterTree({required this.book, required this.onSearch});

  @override
  ConsumerState<_BookVolumeChapterTree> createState() =>
      _BookVolumeChapterTreeState();
}

class _BookVolumeChapterTreeState
    extends ConsumerState<_BookVolumeChapterTree> {
  List<Volume> _volumes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVolumes();
  }

  @override
  void didUpdateWidget(covariant _BookVolumeChapterTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.id != widget.book.id ||
        oldWidget.book.volumeIds != widget.book.volumeIds) {
      _loadVolumes();
    }
  }

  Future<void> _loadVolumes() async {
    final storage = ref.read(storageServiceProvider);
    final vols = await storage.loadVolumes(widget.book.id, widget.book.volumeIds);
    if (!mounted) return;
    setState(() {
      _volumes = vols;
      _loading = false;
    });
  }

  void _reorderVolumes(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final item = _volumes.removeAt(oldIndex);
      _volumes.insert(newIndex.clamp(0, _volumes.length), item);
    });
    _persistVolumeOrder();
  }

  void _moveVolumeUp(int index) {
    if (index <= 0) return;
    setState(() {
      final item = _volumes.removeAt(index);
      _volumes.insert(index - 1, item);
    });
    _persistVolumeOrder();
  }

  void _moveVolumeDown(int index) {
    if (index >= _volumes.length - 1) return;
    setState(() {
      final item = _volumes.removeAt(index);
      _volumes.insert(index + 1, item);
    });
    _persistVolumeOrder();
  }

  void _persistVolumeOrder() {
    ref.read(bookListProvider.notifier).reorderVolumes(
          widget.book.id, _volumes.map((v) => v.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_volumes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无卷，点击 + 或右键标题新建',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ),
      );
    }

    final currentVolumeId = ref.watch(currentVolumeIdProvider);
    final currentChapterId = ref.watch(currentChapterIdProvider);
    final dragMode = ref.watch(dragModeProvider);

    final selectedVolume = _volumes.cast<Volume?>().firstWhere(
        (v) => v!.id == currentVolumeId, orElse: () => null);

    final volumeItems = _volumes.asMap().entries.map((entry) {
      final index = entry.key;
      final vol = entry.value;
      final isFirst = index == 0;
      final isLast = index == _volumes.length - 1;
      final isSelected = currentVolumeId == vol.id;
      return Column(
        key: Key(vol.id),
        children: [
          _TreeItem(
            depth: 0,
            icon: Icons.folder,
            label: vol.title,
            isSelected: isSelected,
            leading: dragMode
                ? ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle, size: 16,
                        color: Theme.of(context).colorScheme.outline.withAlpha(120)),
                  )
                : null,
            onTap: () {
              ref.read(currentVolumeIdProvider.notifier).state = vol.id;
              ref.read(currentChapterIdProvider.notifier).state = null;
            },
            trailing: isSelected
                ? IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    tooltip: '新建章节',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                    onPressed: () {
                      _showCreateChapterDialog(context, ref, vol);
                    },
                  )
                : null,
            menuItems: [
              _MenuItem('重命名', Icons.edit, () {
                _showRenameVolumeDialog(context, ref, vol);
              }),
              _MenuItem('新建章节', Icons.add, () {
                _showCreateChapterDialog(context, ref, vol);
              }),
              if (!isFirst && !dragMode)
                _MenuItem('上移', Icons.arrow_upward, () => _moveVolumeUp(index)),
              if (!isLast && !dragMode)
                _MenuItem('下移', Icons.arrow_downward, () => _moveVolumeDown(index)),
              _MenuItem('删除', Icons.delete, () {
                _showDeleteConfirmDialog(context, ref, vol);
              }),
            ],
          ),
          if (isSelected)
            _ChapterList(bookId: b.id, volume: vol),
        ],
      );
    }).toList();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): () {
          if (currentChapterId != null && selectedVolume != null) {
            _showRenameChapterByCid(
                context, ref, b.id, selectedVolume.id, currentChapterId);
          } else if (currentVolumeId != null && selectedVolume != null) {
            _showRenameVolumeDialog(context, ref, selectedVolume);
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: dragMode
            ? ReorderableListView(
                buildDefaultDragHandles: false,
                onReorder: _reorderVolumes,
                children: volumeItems,
              )
            : ListView(children: volumeItems),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, String title, String initialValue,
      ValueChanged<String> onConfirm) {
    final controller = TextEditingController(text: initialValue);
    doConfirm() {
      final text = controller.text.trim();
      if (text.isNotEmpty) onConfirm(text);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '新名称'),
          onSubmitted: (_) => doConfirm(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: doConfirm,
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showRenameVolumeDialog(
      BuildContext context, WidgetRef ref, Volume volume) {
    _showRenameDialog(context, '重命名卷', volume.title, (newTitle) {
      ref.read(bookListProvider.notifier)
          .renameVolume(widget.book.id, volume.id, newTitle);
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showCreateChapterDialog(
      BuildContext context, WidgetRef ref, Volume volume) {
    final storage = ref.read(storageServiceProvider);
    final controller = TextEditingController();
    // 自动命名：异步加载已有章节名
    Future.microtask(() async {
      if (controller.text.isNotEmpty) return;
      final chapters = await Future.wait(
        volume.chapterIds.map((cid) => storage.loadChapter(widget.book.id, volume.id, cid)),
      );
      final existingNames =
          chapters.whereType<Chapter>().map((c) => c.title).toList();
      controller.text = findAvailableName('新章节', existingNames);
    });

    doCreate() async {
      final title = controller.text.trim();
      if (title.isNotEmpty) {
        final chapter = await ref
            .read(bookListProvider.notifier)
            .createChapter(widget.book.id, volume.id, title);
        ref.read(currentVolumeIdProvider.notifier).state = volume.id;
        ref.read(currentChapterIdProvider.notifier).state = chapter.id;
        if (context.mounted) Navigator.pop(context);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建章节'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '章节名称'),
          onSubmitted: (_) => doCreate(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: doCreate,
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showRenameChapterByCid(BuildContext context, WidgetRef ref,
      String bookId, String volumeId, String chapterId) async {
    final storage = ref.read(storageServiceProvider);
    final chapter = await storage.loadChapter(bookId, volumeId, chapterId);
    if (chapter == null || !context.mounted) return;
    _showRenameDialog(context, '重命名章节', chapter.title, (newTitle) {
      ref.read(bookListProvider.notifier)
          .renameChapter(bookId, volumeId, chapterId, newTitle);
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showDeleteConfirmDialog(
      BuildContext context, WidgetRef ref, Volume volume) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除卷 ${volume.title} 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref
                  .read(bookListProvider.notifier)
                  .deleteVolume(widget.book.id, volume.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ==================== 章节列表 ====================

class _ChapterList extends ConsumerStatefulWidget {
  final String bookId;
  final Volume volume;
  const _ChapterList({required this.bookId, required this.volume});

  @override
  ConsumerState<_ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends ConsumerState<_ChapterList> {
  List<Chapter> _chapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  @override
  void didUpdateWidget(covariant _ChapterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume.id != widget.volume.id ||
        oldWidget.volume.chapterIds != widget.volume.chapterIds) {
      _loadChapters();
    }
  }

  Future<void> _loadChapters() async {
    final storage = ref.read(storageServiceProvider);
    final chapters = await Future.wait(
      widget.volume.chapterIds.map((cid) async {
        final c =
            await storage.loadChapter(widget.bookId, widget.volume.id, cid);
        return c ?? Chapter(id: cid, title: '(已删除)');
      }),
    );
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _loading = false;
    });
  }

  void _reorderChapters(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final item = _chapters.removeAt(oldIndex);
      _chapters.insert(newIndex.clamp(0, _chapters.length), item);
    });
    _persistChapterOrder();
  }

  void _moveChapterUp(int index) {
    if (index <= 0) return;
    setState(() {
      final item = _chapters.removeAt(index);
      _chapters.insert(index - 1, item);
    });
    _persistChapterOrder();
  }

  void _moveChapterDown(int index) {
    if (index >= _chapters.length - 1) return;
    setState(() {
      final item = _chapters.removeAt(index);
      _chapters.insert(index + 1, item);
    });
    _persistChapterOrder();
  }

  void _persistChapterOrder() {
    ref.read(bookListProvider.notifier).reorderChapters(
          widget.bookId,
          widget.volume.id,
          _chapters.map((c) => c.id).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(left: 28),
        child: SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_chapters.isEmpty) return const SizedBox.shrink();

    final currentChapterId = ref.watch(currentChapterIdProvider);
    final dragMode = ref.watch(dragModeProvider);

    final chapterItems = _chapters.asMap().entries.map((entry) {
      final index = entry.key;
      final ch = entry.value;
      final isFirst = index == 0;
      final isLast = index == _chapters.length - 1;
      return _TreeItem(
        key: Key(ch.id),
        depth: 1,
        icon: Icons.article,
        label: ch.title,
        isSelected: currentChapterId == ch.id,
        leading: dragMode
            ? ReorderableDragStartListener(
                index: index,
                child: Icon(Icons.drag_handle, size: 14,
                    color: Theme.of(context).colorScheme.outline.withAlpha(100)),
              )
            : null,
        onTap: () {
          ref.read(currentChapterIdProvider.notifier).state = ch.id;
        },
        menuItems: [
          _MenuItem('重命名', Icons.edit, () {
            _showRenameChapterDialog(context, ref, ch);
          }),
          if (!isFirst && !dragMode)
            _MenuItem('上移', Icons.arrow_upward, () => _moveChapterUp(index)),
          if (!isLast && !dragMode)
            _MenuItem('下移', Icons.arrow_downward, () => _moveChapterDown(index)),
          _MenuItem('删除', Icons.delete, () {
            _showDeleteChapterDialog(context, ref, ch);
          }),
        ],
      );
    }).toList();

    if (dragMode) {
      return ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorder: _reorderChapters,
        children: chapterItems,
      );
    }
    return Column(children: chapterItems);
  }

  void _showRenameChapterDialog(
      BuildContext context, WidgetRef ref, Chapter ch) {
    _showRenameDialog(context, '重命名章节', ch.title, (newTitle) {
      ref.read(bookListProvider.notifier)
          .renameChapter(widget.bookId, widget.volume.id, ch.id, newTitle);
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showDeleteChapterDialog(
      BuildContext context, WidgetRef ref, Chapter ch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除章节 ${ch.title} 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              if (ref.read(currentChapterIdProvider) == ch.id) {
                ref.read(currentChapterIdProvider.notifier).state = null;
              }
              await ref
                  .read(bookListProvider.notifier)
                  .deleteChapter(widget.bookId, widget.volume.id, ch.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ==================== 通用组件 ====================

class _MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _MenuItem(this.label, this.icon, this.onTap);
}

class _TreeItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final List<_MenuItem> menuItems;
  final int depth;
  final Widget? trailing;
  final Widget? leading;

  const _TreeItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.menuItems = const [],
    this.depth = 0,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTapDown: (details) {
        if (menuItems.isNotEmpty) {
          _showContextMenu(context, details.globalPosition);
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 8.0 + depth * 20,
          right: 8,
          top: 4,
          bottom: 4,
        ),
        decoration: depth == 1 && isSelected
            ? BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.zero,
              )
            : null,
        child: Row(
          children: [
            ?leading,
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: menuItems
          .map((item) => PopupMenuItem(
                value: item,
                child: Row(
                  children: [
                    Icon(item.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(item.label),
                  ],
                ),
              ))
          .toList(),
    ).then((value) {
      if (value is _MenuItem) value.onTap();
    });
  }
}
