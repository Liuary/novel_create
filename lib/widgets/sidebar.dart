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

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Container(
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
          ),
          Expanded(
            child: booksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
                  itemBuilder: (context, index) =>
                      _BookTreeTile(book: books[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBookDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建书籍'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '书籍名称'),
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
                final notifier = ref.read(bookListProvider.notifier);
                final book = await notifier.createBook(title);
                ref.read(currentBookIdProvider.notifier).state = book.id;
                ref.read(currentVolumeIdProvider.notifier).state = null;
                ref.read(currentChapterIdProvider.notifier).state = null;
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

class _BookTreeTile extends ConsumerWidget {
  final Book book;
  const _BookTreeTile({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBookId = ref.watch(currentBookIdProvider);
    final isSelected = currentBookId == book.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          _TreeItem(
            icon: Icons.menu_book,
            label: book.title,
            isSelected: isSelected,
            onTap: () {
              ref.read(currentBookIdProvider.notifier).state = book.id;
              ref.read(currentVolumeIdProvider.notifier).state = null;
              ref.read(currentChapterIdProvider.notifier).state = null;
            },
            menuItems: [
              _MenuItem('重命名', Icons.edit, () {
                _showRenameDialog(context, ref, 'book', book.id, book.title);
              }),
              _MenuItem('新建卷', Icons.add, () {
                _showCreateVolumeDialog(context, ref, book.id);
              }),
              _MenuItem('删除', Icons.delete, () {
                _showDeleteConfirm(context, ref, '书籍 ${book.title}', () async {
                  await ref.read(bookListProvider.notifier).deleteBook(book.id);
                  if (currentBookId == book.id) {
                    ref.read(currentBookIdProvider.notifier).state = null;
                  }
                });
              }),
            ],
          ),
          if (isSelected) _VolumeTreeList(book: book),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, String type,
      String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('重命名$type'),
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
                if (type == 'book') {
                  ref
                      .read(bookListProvider.notifier)
                      .renameBook(id, newTitle);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCreateVolumeDialog(
      BuildContext context, WidgetRef ref, String bookId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建卷'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '卷名称'),
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
                await ref
                    .read(bookListProvider.notifier)
                    .createVolume(bookId, title);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('创建'),
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

class _VolumeTreeList extends ConsumerWidget {
  final Book book;
  const _VolumeTreeList({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (book.volumeIds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 32, bottom: 4),
        child: Text('右键书名新建卷',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      );
    }
    return _VolumeListLoader(book: book);
  }
}

class _VolumeListLoader extends ConsumerWidget {
  final Book book;
  const _VolumeListLoader({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final currentVolumeId = ref.watch(currentVolumeIdProvider);

    return FutureBuilder<List<Volume>>(
      future: storage.loadVolumes(book.id, book.volumeIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(left: 32),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return Column(
          children: snapshot.data!.map((vol) {
            final isSelected = currentVolumeId == vol.id;
            return _VolumeTile(
              bookId: book.id,
              volume: vol,
              isSelected: isSelected,
            );
          }).toList(),
        );
      },
    );
  }
}

class _VolumeTile extends ConsumerWidget {
  final String bookId;
  final Volume volume;
  final bool isSelected;

  const _VolumeTile({
    required this.bookId,
    required this.volume,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _TreeItem(
          depth: 1,
          icon: Icons.folder,
          label: volume.title,
          isSelected: isSelected,
          onTap: () {
            ref.read(currentVolumeIdProvider.notifier).state = volume.id;
            ref.read(currentChapterIdProvider.notifier).state = null;
          },
          menuItems: [
            _MenuItem('重命名', Icons.edit, () {
              _showRenameVolumeDialog(context, ref);
            }),
            _MenuItem('新建章节', Icons.add, () {
              _showCreateChapterDialog(context, ref);
            }),
            _MenuItem('删除', Icons.delete, () {
              _showDeleteConfirm(context, ref, '卷 ${volume.title}', () async {
                await ref
                    .read(bookListProvider.notifier)
                    .deleteVolume(bookId, volume.id);
              });
            }),
          ],
        ),
        if (isSelected) _ChapterListLoader(bookId: bookId, volume: volume),
      ],
    );
  }

  void _showRenameVolumeDialog(BuildContext context, WidgetRef ref) {
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
                    .renameVolume(bookId, volume.id, newTitle);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCreateChapterDialog(BuildContext context, WidgetRef ref) {
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
                    .createChapter(bookId, volume.id, title);
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

class _ChapterListLoader extends ConsumerWidget {
  final String bookId;
  final Volume volume;
  const _ChapterListLoader({required this.bookId, required this.volume});

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
            padding: EdgeInsets.only(left: 48),
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
              depth: 2,
              icon: Icons.article,
              label: ch.title,
              isSelected: currentChapterId == ch.id,
              onTap: () {
                ref.read(currentChapterIdProvider.notifier).state = ch.id;
              },
              menuItems: [
                _MenuItem('重命名', Icons.edit, () {
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
                                  .renameChapter(
                                      bookId, volume.id, ch.id, newTitle);
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                }),
                _MenuItem('删除', Icons.delete, () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('确认删除'),
                      content:
                          Text('确定要删除章节 ${ch.title} 吗？此操作不可撤销。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
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
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

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
        decoration: depth == 2 && isSelected
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
