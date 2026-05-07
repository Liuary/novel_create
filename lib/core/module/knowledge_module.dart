import 'package:flutter/widgets.dart';
import 'module_context.dart';

/// 搜索结果条目，由各模块的 [KnowledgeModule.search] 返回。
class SearchResult {
  final String moduleId;
  final String entityId;
  final String title;
  final String snippet;
  final String entityType;
  final Map<String, dynamic>? extra;

  const SearchResult({
    required this.moduleId,
    required this.entityId,
    required this.title,
    required this.snippet,
    required this.entityType,
    this.extra,
  });
}

/// 知识模块抽象基类。
///
/// 所有知识模块（大纲、角色、背景设定、灵感等）必须实现此接口。
/// 实现类需提供模块标识、实体类型，以及章节上下文、链接管理和搜索功能。
abstract class KnowledgeModule {
  /// 模块唯一标识符，用于注册和查找。
  String get moduleId;

  /// UI 中显示的模块名称。
  String get displayName;

  /// 本模块管理的实体类型名称（如 'outline_node', 'character'）。
  /// 用于 entity_links 表中的 from_type / to_type 字段。
  String get entityType;

  /// 初始化模块。由 [ModuleRegistry] 在应用启动时调用。
  /// [context] 提供模块运行所需的数据库、事件总线和章节读写能力。
  Future<void> initialize(ModuleContext context);

  /// 释放模块资源。子类可覆写以清理监听器、定时器等。
  void dispose() {}

  /// 获取指定章节的知识上下文。
  ///
  /// 返回与该章节相关的各类实体信息（如关联的大纲节点、角色等）。
  /// 返回的 Map 键为实体类型名，值为对应实体列表。
  /// 供 EditorPage 在写作时展示上下文面板使用。
  Future<Map<String, dynamic>> getContextForChapter(String chapterId);

  /// 章节保存时的回调。可用于自动提取实体、更新推断属性等。
  Future<void> onChapterSaved(String chapterId, String content);

  /// 章节完成（标记为终稿）时的回调。可用于创建总结、更新角色状态等。
  Future<void> onChapterCompleted(String chapterId, String content);

  /// 构建知识库侧边栏导航面板。返回 null 表示不参与侧边栏展示。
  Widget? buildNavigationPanel(BuildContext context);

  /// 构建知识库编辑器面板。返回 null 表示不需要编辑器。
  Widget? buildEditor(BuildContext context);

  /// 构建实体详情查看器。返回 null 表示不提供详情面板。
  Widget? buildInspector(BuildContext context, String entityId);

  /// 创建实体之间的链接。
  ///
  /// [fromEntityId] 源实体 ID，[toEntityId] 目标实体 ID，[linkType] 链接类型。
  /// 通常由 EditorPage 中的"绑定"操作触发，调用方应检查 [linkType] 避免创建非法链接。
  Future<void> handleLink(
      String fromEntityId, String toEntityId, String linkType);

  /// 在模块数据中搜索，返回匹配的 [SearchResult] 列表。
  /// 供侧边栏全局搜索使用。
  Future<List<SearchResult>> search(String query);
}
