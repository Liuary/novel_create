import '../database/app_database.dart';
import '../event/event_bus.dart';
import '../repositories/entity_link_repository.dart';

class ModuleContext {
  final AppDatabase database;
  final EventBus eventBus;
  final EntityLinkRepository linkRepo;
  final Future<String> Function(String chapterId) readChapterContent;
  final Future<void> Function(String chapterId, String content) writeChapterContent;

  /// 当前选中的书籍ID，null 表示全局/公共知识库
  String? currentBookId;

  /// 当前选中的章节ID
  String? currentChapterId;

  ModuleContext({
    required this.database,
    required this.eventBus,
    required this.linkRepo,
    required this.readChapterContent,
    required this.writeChapterContent,
    this.currentBookId,
    this.currentChapterId,
  });
}
