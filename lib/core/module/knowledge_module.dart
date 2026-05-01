import 'package:flutter/widgets.dart';
import 'module_context.dart';

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

abstract class KnowledgeModule {
  String get moduleId;
  String get displayName;

  Future<void> initialize(ModuleContext context);

  Future<Map<String, dynamic>> getContextForChapter(String chapterId);

  Future<void> onChapterSaved(String chapterId, String content);

  Future<void> onChapterCompleted(String chapterId, String content);

  Widget? buildNavigationPanel(BuildContext context);
  Widget? buildEditor(BuildContext context);
  Widget? buildInspector(BuildContext context, String entityId);

  Future<void> handleLink(
      String fromEntityId, String toEntityId, String linkType);

  Future<List<SearchResult>> search(String query);
}
