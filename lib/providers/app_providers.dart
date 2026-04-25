import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../models/volume.dart';
import '../models/chapter.dart';
import '../models/user_config.dart';
import '../services/storage_service.dart';
import '../services/toast_service.dart';

const _uuid = Uuid();

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

/// 用户配置 - AsyncNotifier
final userConfigProvider =
    AsyncNotifierProvider<UserConfigNotifier, UserConfig>(
  UserConfigNotifier.new,
);

class UserConfigNotifier extends AsyncNotifier<UserConfig> {
  @override
  Future<UserConfig> build() async {
    final storage = ref.read(storageServiceProvider);
    return await storage.loadConfig() ?? UserConfig.defaults();
  }

  Future<void> updateConfig(UserConfig config) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveConfig(config);
    state = AsyncData(config);
  }
}

/// 是否有未保存的编辑内容（供应用退出时使用）
final hasUnsavedChangesProvider = StateProvider<bool>((ref) => false);

/// 退出时保存回调（由 EditorPage 注册）
final onExitSaveProvider = StateProvider<Future<void> Function()?>(
  (ref) => null,
);

/// 书籍列表 - AsyncNotifier
final bookListProvider = AsyncNotifierProvider<BookListNotifier, List<Book>>(
  BookListNotifier.new,
);

class BookListNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    final storage = ref.read(storageServiceProvider);
    final ids = await storage.loadBooksIndex();
    final books = <Book>[];
    for (final id in ids) {
      final book = await storage.loadBook(id);
      if (book != null) books.add(book);
    }
    return books;
  }

  Future<Book> createBook(String title) async {
    final storage = ref.read(storageServiceProvider);
    final book = Book(id: _uuid.v4(), title: title);
    await storage.saveBook(book);
    ref.invalidateSelf();
    return book;
  }

  Future<void> deleteBook(String bookId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteBook(bookId);
    ref.invalidateSelf();
  }

  Future<void> renameBook(String bookId, String newTitle) async {
    final storage = ref.read(storageServiceProvider);
    final book = await storage.loadBook(bookId);
    if (book != null) {
      book.title = newTitle;
      book.updatedAt = DateTime.now();
      await storage.saveBook(book);
      ref.invalidateSelf();
    }
  }

  Future<Volume> createVolume(String bookId, String title) async {
    final storage = ref.read(storageServiceProvider);
    final book = await storage.loadBook(bookId);
    if (book == null) throw Exception('书籍不存在');
    final volume = Volume(id: _uuid.v4(), title: title);
    await storage.saveVolume(bookId, volume);
    book.volumeIds.add(volume.id);
    book.updatedAt = DateTime.now();
    await storage.saveBook(book);
    ref.invalidateSelf();
    return volume;
  }

  Future<Chapter> createChapter(
      String bookId, String volumeId, String title) async {
    final storage = ref.read(storageServiceProvider);
    final chapter = Chapter(id: _uuid.v4(), title: title);
    await storage.saveChapter(bookId, volumeId, chapter);
    final volume = await storage.loadVolume(bookId, volumeId);
    if (volume != null) {
      volume.chapterIds.add(chapter.id);
      volume.updatedAt = DateTime.now();
      await storage.saveVolume(bookId, volume);
    }
    ref.invalidateSelf();
    return chapter;
  }

  Future<void> renameVolume(String bookId, String volumeId, String newTitle) async {
    final storage = ref.read(storageServiceProvider);
    final volume = await storage.loadVolume(bookId, volumeId);
    if (volume != null) {
      volume.title = newTitle;
      volume.updatedAt = DateTime.now();
      await storage.saveVolume(bookId, volume);
      ref.invalidateSelf();
    }
  }

  Future<void> renameChapter(
      String bookId, String volumeId, String chapterId, String newTitle) async {
    final storage = ref.read(storageServiceProvider);
    final chapter = await storage.loadChapter(bookId, volumeId, chapterId);
    if (chapter != null) {
      chapter.title = newTitle;
      chapter.updatedAt = DateTime.now();
      await storage.saveChapter(bookId, volumeId, chapter);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteVolume(String bookId, String volumeId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteVolume(bookId, volumeId);
    final book = await storage.loadBook(bookId);
    if (book != null) {
      book.volumeIds.remove(volumeId);
      book.updatedAt = DateTime.now();
      await storage.saveBook(book);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteChapter(
      String bookId, String volumeId, String chapterId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteChapter(bookId, volumeId, chapterId);
    final volume = await storage.loadVolume(bookId, volumeId);
    if (volume != null) {
      volume.chapterIds.remove(chapterId);
      volume.updatedAt = DateTime.now();
      await storage.saveVolume(bookId, volume);
    }
    ref.invalidateSelf();
  }
}

/// 当前选中的书籍ID
final currentBookIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的卷ID
final currentVolumeIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的章节ID
final currentChapterIdProvider = StateProvider<String?>((ref) => null);

/// 全局消息提示
final toastProvider = NotifierProvider<ToastNotifier, List<ToastMessage>>(
  ToastNotifier.new,
);

/// 当前书籍详情（派生自 bookListProvider）
final currentBookProvider = Provider<Book?>((ref) {
  final bookId = ref.watch(currentBookIdProvider);
  if (bookId == null) return null;
  final booksAsync = ref.watch(bookListProvider);
  return booksAsync.whenOrNull(data: (books) {
    try {
      return books.firstWhere((b) => b.id == bookId);
    } catch (_) {
      return null;
    }
  });
});
