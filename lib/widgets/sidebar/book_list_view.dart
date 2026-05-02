import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import 'tree_item.dart';
import 'menu_item.dart';
import 'rename_dialog.dart';
import '../../models/book.dart';

class BookListView extends ConsumerWidget {
  final AsyncValue<List<Book>> booksAsync;
  const BookListView({super.key, required this.booksAsync});

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
            return TreeItem(
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
                MenuItem('重命名', Icons.edit, () {
                  showRenameDialog(context, '重命名书籍', book.title, (newTitle) {
                    ref.read(bookListProvider.notifier).renameBook(book.id, newTitle);
                    if (context.mounted) Navigator.pop(context);
                  });
                }),
                MenuItem('删除', Icons.delete, () {
                  _showDeleteConfirmDialog(context, ref, book);
                }),
              ],
            );
          },
        );
      },
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
