import '../database/app_database.dart';
import '../event/event_bus.dart';
import '../repositories/entity_link_repository.dart';

/// 模块运行上下文，由 [KnowledgeModule.initialize] 传入。
///
/// 提供模块所需的数据库访问、事件通信、链接管理和章节读写能力。
/// 模块通过此上下文与其它模块及核心系统协作，无需直接依赖具体实现。
class ModuleContext {
  /// 数据库实例，模块可执行查询和写入操作。
  final AppDatabase database;

  /// 事件总线，模块可发布和订阅事件（如章节保存、实体更新等）。
  final EventBus eventBus;

  /// 实体链接仓储，用于创建和查询实体间的关联关系。
  final EntityLinkRepository linkRepo;

  /// 读取指定章节的完整内容。入参 [chapterId]，返回章节正文文本。
  final Future<String> Function(String chapterId) readChapterContent;

  /// 写入指定章节的内容。入参 [chapterId] 和 [content]。
  final Future<void> Function(String chapterId, String content) writeChapterContent;

  ModuleContext({
    required this.database,
    required this.eventBus,
    required this.linkRepo,
    required this.readChapterContent,
    required this.writeChapterContent,
  });
}
