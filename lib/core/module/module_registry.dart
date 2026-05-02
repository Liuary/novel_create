import 'knowledge_module.dart';
import 'module_context.dart';

class ModuleRegistry {
  final List<KnowledgeModule> _modules = [];

  List<KnowledgeModule> get modules => List.unmodifiable(_modules);

  void register(KnowledgeModule module) {
    if (_modules.any((m) => m.moduleId == module.moduleId)) {
      throw StateError('模块 ${module.moduleId} 已注册');
    }
    _modules.add(module);
  }

  KnowledgeModule? getById(String moduleId) {
    try {
      return _modules.firstWhere((m) => m.moduleId == moduleId);
    } catch (_) {
      return null;
    }
  }

  Future<void> initializeAll(ModuleContext context) async {
    for (final module in _modules) {
      await module.initialize(context);
    }
  }

  void disposeAll() {
    for (final module in _modules) {
      module.dispose();
    }
  }

  Future<void> notifyChapterSaved(String chapterId, String content) async {
    for (final module in _modules) {
      await module.onChapterSaved(chapterId, content);
    }
  }

  Future<void> notifyChapterCompleted(String chapterId, String content) async {
    for (final module in _modules) {
      await module.onChapterCompleted(chapterId, content);
    }
  }

  Future<List<SearchResult>> searchAll(String query) async {
    final results = <SearchResult>[];
    for (final module in _modules) {
      results.addAll(await module.search(query));
    }
    return results;
  }

  Future<Map<String, dynamic>> assembleContext(String chapterId) async {
    final context = <String, dynamic>{};
    for (final module in _modules) {
      context[module.moduleId] = await module.getContextForChapter(chapterId);
    }
    return context;
  }
}
