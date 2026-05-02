import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../models/volume.dart';
import '../providers/app_providers.dart';
import '../services/storage_service.dart';
import 'search_util.dart';
import 'sidebar/book_list_view.dart';
import 'sidebar/knowledge_base_panel.dart';
import 'sidebar/book_volume_chapter_tree.dart';

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
                        ? BookVolumeChapterTree(
                            book: selectedBook,
                            onSearch: (vols) => _performSearch(
                                selectedBook.id, vols, currentChapterId,
                                currentVolumeId),
                          )
                        : BookListView(booksAsync: booksAsync))
                    : KnowledgeBasePanel(currentBookId: currentBookId),
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


