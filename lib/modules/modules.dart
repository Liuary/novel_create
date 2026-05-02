import '../core/module/knowledge_module.dart';
import 'outline/outline_module.dart';
// 新增模块在此 import 并加入列表

List<KnowledgeModule> createAllModules() => [
  OutlineModule(),
  // CharacterModule(),   // 2.3a
  // WorldModule(),       // 2.3b
  // InspirationModule(), // 2.4a
  // ItemModule(),        // 2.4b
];
