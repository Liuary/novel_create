import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';
import '../models/volume.dart';
import '../models/chapter.dart';

class StorageService {
  static StorageService? _instance;
  late String _dataDir;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _dataDir = p.join(appDir.path, 'novel_create');
    final dir = Directory(_dataDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  String get dataDir => _dataDir;

  /// 书籍列表文件路径
  String get _booksIndexPath => p.join(_dataDir, '_books.json');

  /// 获取指定书籍的目录
  String _bookDir(String bookId) => p.join(_dataDir, bookId);

  // ==================== 书籍 ====================

  Future<void> saveBooksIndex(List<String> bookIds) async {
    final file = File(_booksIndexPath);
    await file.writeAsString(jsonEncode(bookIds), flush: true);
  }

  Future<List<String>> loadBooksIndex() async {
    final file = File(_booksIndexPath);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    final list = jsonDecode(content) as List<dynamic>;
    return list.map((e) => e as String).toList();
  }

  Future<void> saveBook(Book book) async {
    final dir = Directory(_bookDir(book.id));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, 'book.json'));
    await file.writeAsString(book.toJsonString(), flush: true);

    final index = await loadBooksIndex();
    if (!index.contains(book.id)) {
      index.add(book.id);
      await saveBooksIndex(index);
    }
  }

  Future<Book?> loadBook(String bookId) async {
    final file = File(p.join(_bookDir(bookId), 'book.json'));
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return Book.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  Future<void> deleteBook(String bookId) async {
    final dir = Directory(_bookDir(bookId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    final index = await loadBooksIndex();
    index.remove(bookId);
    await saveBooksIndex(index);
  }

  // ==================== 卷 ====================

  Future<void> saveVolume(String bookId, Volume volume) async {
    final dir = Directory(p.join(_bookDir(bookId), 'volumes'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, '${volume.id}.json'));
    await file.writeAsString(volume.toJsonString(), flush: true);
  }

  Future<Volume?> loadVolume(String bookId, String volumeId) async {
    final file =
        File(p.join(_bookDir(bookId), 'volumes', '$volumeId.json'));
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return Volume.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  Future<List<Volume>> loadVolumes(String bookId, List<String> volumeIds) async {
    final volumes = <Volume>[];
    for (final vid in volumeIds) {
      final v = await loadVolume(bookId, vid);
      if (v != null) volumes.add(v);
    }
    return volumes;
  }

  Future<void> deleteVolume(String bookId, String volumeId) async {
    final volDir = Directory(p.join(_bookDir(bookId), 'volumes', volumeId));
    if (await volDir.exists()) {
      await volDir.delete(recursive: true);
    }
    final file =
        File(p.join(_bookDir(bookId), 'volumes', '$volumeId.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ==================== 章节 ====================

  Future<void> saveChapter(
      String bookId, String volumeId, Chapter chapter) async {
    final dir =
        Directory(p.join(_bookDir(bookId), 'volumes', volumeId));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, '${chapter.id}.json'));
    await file.writeAsString(chapter.toJsonString(), flush: true);
  }

  Future<Chapter?> loadChapter(
      String bookId, String volumeId, String chapterId) async {
    final file = File(
        p.join(_bookDir(bookId), 'volumes', volumeId, '$chapterId.json'));
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return Chapter.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  Future<void> deleteChapter(
      String bookId, String volumeId, String chapterId) async {
    final file = File(
        p.join(_bookDir(bookId), 'volumes', volumeId, '$chapterId.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
