import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/volume.dart';
import '../../models/chapter.dart';
import 'tree_item.dart';
import 'menu_item.dart';
import 'rename_dialog.dart';

class ChapterList extends ConsumerStatefulWidget {
  final String bookId;
  final Volume volume;
  const ChapterList({super.key, required this.bookId, required this.volume});

  @override
  ConsumerState<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends ConsumerState<ChapterList> {
  List<Chapter> _chapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  @override
  void didUpdateWidget(covariant ChapterList oldWidget) {
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
      return TreeItem(
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
          MenuItem('重命名', Icons.edit, () {
            _showRenameChapterDialog(context, ref, ch);
          }),
          if (!isFirst && !dragMode)
            MenuItem('上移', Icons.arrow_upward, () => _moveChapterUp(index)),
          if (!isLast && !dragMode)
            MenuItem('下移', Icons.arrow_downward, () => _moveChapterDown(index)),
          MenuItem('删除', Icons.delete, () {
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
    showRenameDialog(context, '重命名章节', ch.title, (newTitle) {
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
