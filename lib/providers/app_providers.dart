import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:uuid/uuid.dart';
import '../core/database/database_service.dart';
import '../core/event/event_bus.dart';
import '../core/module/module_registry.dart';
import '../core/repositories/book_repository.dart';
import '../core/repositories/volume_repository.dart';
import '../core/repositories/chapter_repository.dart';
import '../core/repositories/entity_link_repository.dart';
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

// ==================== 核心服务 ====================

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final eventBusProvider = Provider<EventBus>((ref) {
  return EventBus();
});

final moduleRegistryProvider = Provider<ModuleRegistry>((ref) {
  return ModuleRegistry();
});

final bookRepoProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.read(databaseServiceProvider).database);
});

final volumeRepoProvider = Provider<VolumeRepository>((ref) {
  return VolumeRepository(ref.read(databaseServiceProvider).database);
});

final chapterRepoProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository(ref.read(databaseServiceProvider).database);
});

final entityLinkRepoProvider = Provider<EntityLinkRepository>((ref) {
  return EntityLinkRepository(ref.read(databaseServiceProvider).database);
});

// ==================== 用户配置 ====================

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

// ==================== UI 状态 ====================

/// 是否有未保存的编辑内容（供应用退出时使用）
final hasUnsavedChangesProvider = StateProvider<bool>((ref) => false);

/// 退出时保存回调（由 EditorPage 注册）
final onExitSaveProvider = StateProvider<Future<void> Function()?>(
  (ref) => null,
);

/// 侧边栏当前选中的 Tab: 'tree' 或 'knowledge'
final sidebarTabProvider = StateProvider<String>((ref) => 'tree');

/// 知识库面板当前激活的模块ID，null 表示未选择
final activeKnowledgeModuleIdProvider = StateProvider<String?>((ref) => null);

/// 拖拽排序模式开关
final dragModeProvider = StateProvider<bool>((ref) => false);

/// 自动打开编辑器内联搜索的查询词（由侧边栏搜索结果触发）
final autoInlineSearchProvider = StateProvider<String?>((ref) => null);

// ==================== 书籍列表 ====================

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

  // ==================== 书籍 ====================

  Future<Book> createBook(String title) async {
    final storage = ref.read(storageServiceProvider);
    final book = Book(id: _uuid.v4(), title: title);
    await storage.saveBook(book);
    _syncBookToDb(book);
    ref.invalidateSelf();
    return book;
  }

  Future<void> deleteBook(String bookId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteBook(bookId);
    _deleteBookFromDb(bookId);
    ref.invalidateSelf();
  }

  Future<void> renameBook(String bookId, String newTitle) async {
    final storage = ref.read(storageServiceProvider);
    final book = await storage.loadBook(bookId);
    if (book != null) {
      book.title = newTitle;
      book.updatedAt = DateTime.now();
      await storage.saveBook(book);
      _syncBookToDb(book);
      ref.invalidateSelf();
    }
  }

  // ==================== 卷 ====================

  Future<Volume> createVolume(String bookId, String title) async {
    final storage = ref.read(storageServiceProvider);
    final book = await storage.loadBook(bookId);
    if (book == null) throw Exception('书籍不存在');
    final volume = Volume(id: _uuid.v4(), title: title);
    await storage.saveVolume(bookId, volume);
    book.volumeIds.add(volume.id);
    book.updatedAt = DateTime.now();
    await storage.saveBook(book);
    _syncVolumeToDb(volume, bookId);
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
    _syncChapterToDb(chapter, volumeId);
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
      _syncVolumeToDb(volume, bookId);
      ref.invalidateSelf();
    }
  }

  Future<void> reorderVolume(String bookId, int oldIndex, int newIndex) async {
    final storage = ref.read(storageServiceProvider);
    final book = await storage.loadBook(bookId);
    if (book == null) return;
    final item = book.volumeIds.removeAt(oldIndex);
    book.volumeIds.insert(newIndex.clamp(0, book.volumeIds.length), item);
    book.updatedAt = DateTime.now();
    await storage.saveBook(book);
    ref.invalidateSelf();
  }

  Future<void> reorderVolumes(String bookId, List<String> newOrder) async {
    final storage = ref.read(storageServiceProvider);
    final book = await storage.loadBook(bookId);
    if (book == null) return;
    book.volumeIds = List.from(newOrder);
    book.updatedAt = DateTime.now();
    await storage.saveBook(book);
    ref.invalidateSelf();
  }

  Future<void> renameChapter(
      String bookId, String volumeId, String chapterId, String newTitle) async {
    final storage = ref.read(storageServiceProvider);
    final chapter = await storage.loadChapter(bookId, volumeId, chapterId);
    if (chapter != null) {
      chapter.title = newTitle;
      chapter.updatedAt = DateTime.now();
      await storage.saveChapter(bookId, volumeId, chapter);
      _syncChapterToDb(chapter, volumeId);
    }
    ref.invalidateSelf();
  }

  Future<void> reorderChapter(
      String bookId, String volumeId, int oldIndex, int newIndex) async {
    final storage = ref.read(storageServiceProvider);
    final volume = await storage.loadVolume(bookId, volumeId);
    if (volume == null) return;
    final item = volume.chapterIds.removeAt(oldIndex);
    volume.chapterIds.insert(newIndex.clamp(0, volume.chapterIds.length), item);
    volume.updatedAt = DateTime.now();
    await storage.saveVolume(bookId, volume);
    ref.invalidateSelf();
  }

  Future<void> reorderChapters(
      String bookId, String volumeId, List<String> newOrder) async {
    final storage = ref.read(storageServiceProvider);
    final volume = await storage.loadVolume(bookId, volumeId);
    if (volume == null) return;
    volume.chapterIds = List.from(newOrder);
    volume.updatedAt = DateTime.now();
    await storage.saveVolume(bookId, volume);
    ref.invalidateSelf();
  }

  Future<void> deleteVolume(String bookId, String volumeId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteVolume(bookId, volumeId);
    _deleteVolumeFromDb(volumeId);
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
    _deleteChapterFromDb(chapterId);
    final volume = await storage.loadVolume(bookId, volumeId);
    if (volume != null) {
      volume.chapterIds.remove(chapterId);
      volume.updatedAt = DateTime.now();
      await storage.saveVolume(bookId, volume);
    }
    ref.invalidateSelf();
  }

  // ==================== 数据库同步 ====================

  void _syncBookToDb(Book book) {
    try {
      ref.read(bookRepoProvider).upsert(
            id: book.id,
            name: book.title,
            createdAt: book.createdAt,
            updatedAt: book.updatedAt,
          );
    } catch (_) {}
  }

  void _syncVolumeToDb(Volume volume, String bookId) {
    try {
      ref.read(volumeRepoProvider).upsert(
            id: volume.id,
            bookId: bookId,
            name: volume.title,
            sortOrder: 0,
            createdAt: volume.createdAt,
            updatedAt: volume.updatedAt,
          );
    } catch (_) {}
  }

  void _syncChapterToDb(Chapter chapter, String volumeId) {
    try {
      final filePath = ref
          .read(storageServiceProvider)
          .dataDir;
      ref.read(chapterRepoProvider).upsert(
            id: chapter.id,
            volumeId: volumeId,
            name: chapter.title,
            filePath: filePath,
            sortOrder: 0,
            summary: chapter.summary,
            status: 'draft',
            wordCount: chapter.content.replaceAll(RegExp(r'\s'), '').length,
            createdAt: chapter.createdAt,
            updatedAt: chapter.updatedAt,
          );
    } catch (_) {}
  }

  void _deleteBookFromDb(String bookId) {
    try {
      ref.read(bookRepoProvider).delete(bookId);
    } catch (_) {}
  }

  void _deleteVolumeFromDb(String volumeId) {
    try {
      ref.read(volumeRepoProvider).delete(volumeId);
    } catch (_) {}
  }

  void _deleteChapterFromDb(String chapterId) {
    try {
      ref.read(chapterRepoProvider).delete(chapterId);
    } catch (_) {}
  }
}

/// 在已有名称列表中找到不重名的名称：基名 → 基名2 → 基名3...
String findAvailableName(String base, List<String> existing) {
  if (!existing.contains(base)) return base;
  int i = 2;
  while (existing.contains('$base$i')) {
    i++;
  }
  return '$base$i';
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
