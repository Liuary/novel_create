import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/book.dart';
import '../../models/volume.dart';
import '../../models/chapter.dart';
import 'tree_item.dart';
import 'menu_item.dart';
import 'rename_dialog.dart';
import 'chapter_list.dart';

class BookVolumeChapterTree extends ConsumerStatefulWidget {
  final Book book;
  final void Function(List<Volume>) onSearch;
  const BookVolumeChapterTree({super.key, required this.book, required this.onSearch});

  @override
  ConsumerState<BookVolumeChapterTree> createState() =>
      _BookVolumeChapterTreeState();
}

class _BookVolumeChapterTreeState
    extends ConsumerState<BookVolumeChapterTree> {
  List<Volume> _volumes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVolumes();
  }

  @override
  void didUpdateWidget(covariant BookVolumeChapterTree oldWidget) {
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
          TreeItem(
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
              MenuItem('重命名', Icons.edit, () {
                _showRenameVolumeDialog(context, ref, vol);
              }),
              MenuItem('新建章节', Icons.add, () {
                _showCreateChapterDialog(context, ref, vol);
              }),
              if (!isFirst && !dragMode)
                MenuItem('上移', Icons.arrow_upward, () => _moveVolumeUp(index)),
              if (!isLast && !dragMode)
                MenuItem('下移', Icons.arrow_downward, () => _moveVolumeDown(index)),
              MenuItem('删除', Icons.delete, () {
                _showDeleteConfirmDialog(context, ref, vol);
              }),
            ],
          ),
          if (isSelected)
            ChapterList(bookId: b.id, volume: vol),
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

  void _showRenameVolumeDialog(
      BuildContext context, WidgetRef ref, Volume volume) {
    showRenameDialog(context, '重命名卷', volume.title, (newTitle) {
      ref.read(bookListProvider.notifier)
          .renameVolume(widget.book.id, volume.id, newTitle);
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showCreateChapterDialog(
      BuildContext context, WidgetRef ref, Volume volume) {
    final storage = ref.read(storageServiceProvider);
    final controller = TextEditingController();
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
    showRenameDialog(context, '重命名章节', chapter.title, (newTitle) {
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
