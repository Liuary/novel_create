import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';
import 'storage_service.dart';

class ExportService {
  final StorageService _storage = StorageService.instance;

  /// 导出整本书为 Markdown
  Future<String> exportBookAsMarkdown(Book book) async {
    final buffer = StringBuffer();
    buffer.writeln('# ${book.title}');
    if (book.author.isNotEmpty) {
      buffer.writeln('> 作者: ${book.author}');
    }
    if (book.description.isNotEmpty) {
      buffer.writeln('> ${book.description}');
    }
    buffer.writeln();

    for (final vid in book.volumeIds) {
      final volume = await _storage.loadVolume(book.id, vid);
      if (volume == null) continue;
      buffer.writeln('## ${volume.title}');
      if (volume.summary.isNotEmpty) {
        buffer.writeln('*${volume.summary}*');
      }
      buffer.writeln();

      for (final cid in volume.chapterIds) {
        final chapter =
            await _storage.loadChapter(book.id, volume.id, cid);
        if (chapter == null) continue;
        buffer.writeln('### ${chapter.title}');
        buffer.writeln();
        if (chapter.content.isNotEmpty) {
          buffer.writeln(chapter.content);
          buffer.writeln();
        }
        buffer.writeln();
        buffer.writeln('---');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// 保存导出文件
  Future<String> saveExportFile(String fileName, String content) async {
    final downloadsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(downloadsDir.path, 'novel_create_exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    final file = File(p.join(exportDir.path, fileName));
    await file.writeAsString(content, flush: true);
    return file.path;
  }
}
