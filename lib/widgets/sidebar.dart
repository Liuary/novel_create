import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../models/volume.dart';
import '../models/chapter.dart';
import '../providers/app_providers.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(bookListProvider);
    final currentBookId = ref.watch(currentBookIdProvider);
    final selectedBook = booksAsync.whenOrNull(data: (books) {
      if (currentBookId == null) return null;
      try {
        return books.firstWhere((b) => b.id == currentBookId);
      } catch (_) {
        return null;
      }
    });

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          _buildHeader(context, ref, selectedBook, currentBookId),
          Expanded(
            child: selectedBook != null
                ? _VolumeAndChapterTree(book: selectedBook)
                : _BookListView(booksAsync: booksAsync),
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
        },
        onSecondaryTapDown: (details) {
          _showBookContextMenu(context, ref, selectedBook, details.globalPosition);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.arrow_back, size: 16, color: theme.colorScheme.primary),
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
                onPressed: () => _showCreateVolumeDialog(context, ref, selectedBook.id),
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
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('重命名')]),
          onTap: () => _showRenameBookDialog(context, ref, book),
        ),
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('新建卷')]),
          onTap: () => _showCreateVolumeDialog(context, ref, book.id),
        ),
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.delete, size: 18), SizedBox(width: 8), Text('删除')]),
          onTap: () => _showDeleteConfirm(context, ref, '书籍 ${book.title}', () async {
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

  void _showCreateVolumeDialog(BuildContext context, WidgetRef ref, String bookId) {
    _showTextInputDialog(
      context: context,
      title: '新建卷',
      hintText: '卷名称',
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
    required FutureOr<void> Function(String) onConfirm,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hintText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                await onConfirm(text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
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
              child: Text('暂无书籍，点击 + 创建', style: TextStyle(color: Colors.grey)),
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
                ref.read(bookListProvider.notifier).renameBook(book.id, newTitle);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Book book) {
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

// ==================== 卷和章树（选中书籍后显示） ====================

class _VolumeAndChapterTree extends ConsumerWidget {
  final Book book;
  const _VolumeAndChapterTree({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (book.volumeIds.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无卷，点击 + 或右键标题新建',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ),
      );
    }
    final storage = ref.watch(storageServiceProvider);
    final currentVolumeId = ref.watch(currentVolumeIdProvider);

    return FutureBuilder<List<Volume>>(
      future: storage.loadVolumes(book.id, book.volumeIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.map((vol) {
            final isSelected = currentVolumeId == vol.id;
            return Column(
              children: [
                _TreeItem(
                  depth: 0,
                  icon: Icons.folder,
                  label: vol.title,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(currentVolumeIdProvider.notifier).state = vol.id;
                    ref.read(currentChapterIdProvider.notifier).state = null;
                  },
                  menuItems: [
                    _MenuItem('重命名', Icons.edit, () {
                      _showRenameVolumeDialog(context, ref, vol);
                    }),
                    _MenuItem('新建章节', Icons.add, () {
                      _showCreateChapterDialog(context, ref, vol);
                    }),
                    _MenuItem('删除', Icons.delete, () {
                      _showDeleteConfirmDialog(context, ref, vol);
                    }),
                  ],
                ),
                if (isSelected) _ChapterList(bookId: book.id, volume: vol),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  void _showRenameVolumeDialog(BuildContext context, WidgetRef ref, Volume volume) {
    final controller = TextEditingController(text: volume.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名卷'),
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
                    .renameVolume(book.id, volume.id, newTitle);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCreateChapterDialog(BuildContext context, WidgetRef ref, Volume volume) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建章节'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '章节名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                final chapter = await ref
                    .read(bookListProvider.notifier)
                    .createChapter(book.id, volume.id, title);
                ref.read(currentChapterIdProvider.notifier).state = chapter.id;
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Volume volume) {
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
                  .deleteVolume(book.id, volume.id);
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

class _ChapterList extends ConsumerWidget {
  final String bookId;
  final Volume volume;
  const _ChapterList({required this.bookId, required this.volume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final currentChapterId = ref.watch(currentChapterIdProvider);

    return FutureBuilder<List<Chapter>>(
      future: Future.wait(
        volume.chapterIds.map((cid) async {
          final c = await storage.loadChapter(bookId, volume.id, cid);
          return c ?? Chapter(id: cid, title: '(已删除)');
        }),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(left: 28),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return Column(
          children: snapshot.data!.map((ch) {
            return _TreeItem(
              depth: 1,
              icon: Icons.article,
              label: ch.title,
              isSelected: currentChapterId == ch.id,
              onTap: () {
                ref.read(currentChapterIdProvider.notifier).state = ch.id;
              },
              menuItems: [
                _MenuItem('重命名', Icons.edit, () {
                  _showRenameChapterDialog(context, ref, ch);
                }),
                _MenuItem('删除', Icons.delete, () {
                  _showDeleteChapterDialog(context, ref, ch);
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  void _showRenameChapterDialog(BuildContext context, WidgetRef ref, Chapter ch) {
    final controller = TextEditingController(text: ch.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名章节'),
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
                    .renameChapter(bookId, volume.id, ch.id, newTitle);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteChapterDialog(BuildContext context, WidgetRef ref, Chapter ch) {
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
                  .deleteChapter(bookId, volume.id, ch.id);
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

  const _TreeItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.menuItems = const [],
    this.depth = 0,
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
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.zero,
              )
            : null,
        child: Row(
          children: [
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
