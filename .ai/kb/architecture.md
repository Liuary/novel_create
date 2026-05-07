# 架构决策与技术选型

> 最后更新：2026-05-07

## 整体架构

```
lib/
├── main.dart                    # 应用入口，注册模块
├── core/                        # 核心基础设施层
│   ├── database/                #   Drift (SQLite) 数据库定义与生成
│   ├── event/                   #   事件总线
│   ├── module/                  #   模块抽象层（ModuleRegistry + ModuleContext + KnowledgeModule）
│   ├── repositories/            #   数据仓库（Book/Volume/Chapter/EntityLink）
│   └── utils/                   #   通用工具
├── models/                      # 纯数据模型（Book/Chapter/Volume/Annotation/UserConfig）
├── modules/                     # 可插拔功能模块
│   ├── character/               #   角色模块（model + repository + KnowledgeModule 实现）
│   └── outline/                 #   大纲模块（model + repository + KnowledgeModule 实现 + widgets/）
├── pages/                       # 页面（HomePage）
├── providers/                   # 状态管理（Riverpod，集中在 app_providers.dart）
├── services/                    # 服务层（StorageService/ToastService）
├── utils/                       # 工具函数
└── widgets/                     # UI 组件
    ├── editor/                  #   编辑器相关
    ├── knowledge/               #   知识库相关
    └── sidebar/                 #   侧边栏相关
```

## 技术选型

| 图层 | 选型 | 理由 |
|------|------|------|
| 状态管理 | Riverpod ^3.3.1 | 编译时安全、无 BuildContext 依赖、模块化 Provider 定义 |
| 数据库 | Drift ^2.26.0 + SQLite | 类型安全 ORM、编译期 SQL 校验、自动生成代码 |
| 数据存储 | JSON 文件（正文）+ SQLite（元数据/关联） | 正文大文本不适合 SQL，元数据需要结构化查询 |
| 事件通信 | EventBus（自建） | 模块间解耦，为阶段3 AI 协作准备 |
| 模块架构 | ModuleRegistry + KnowledgeModule 抽象 | 可插拔、可并行开发、运行时可发现 |

## 关键架构决策

### [+] 模块注册去硬编码（2.arch-A）

`lib/modules/modules.dart` 通过 `createAllModules()` 工厂函数集中管理模块实例，`main.dart` 循环注册，新增模块无需修改 `main.dart`。

### [+] ModuleContext 规范化（2.arch-B）

`ModuleContext` 为 plain Dart 对象（非 Riverpod 管理），字段在初始化时赋值且永不替换。各模块通过 `_context` 引用访问数据库、事件总线等基础设施。

### [+] Repository 分层

| 层级 | 位置 | 职责 |
|------|------|------|
| 核心仓储 | `lib/core/repositories/` | 书籍/卷/章节/EntityLink 的基础 CRUD |
| 模块仓储 | `lib/modules/{module}/xxx_repository.dart` | 模块专属数据的 CRUD + 级联操作 |

模块仓储的 `delete()` 应使用 `_db.transaction()` 确保级联删除原子性。核心仓储的单表删除也应包裹事务以保持风格一致。

### [+] 双重存储策略

正文内容存 JSON 文件（`StorageService`），元数据和关联存 SQLite（Drift）。`BookListNotifier` 中的 `_sync*ToDb` / `_delete*FromDb` 方法负责双写同步。

**已知限制**：当前未实现跨存储事务（如正文保存成功但 DB 同步失败），需作为阶段2末尾或阶段3的重点处理项。

### [+] KnowledgeModule 接口

```dart
abstract class KnowledgeModule {
  String get moduleId;       // 模块唯一标识
  String get displayName;    // UI 显示名称
  String get entityType;     // 实体类型名（如 'character', 'outline_node'）
  Future<void> initialize(ModuleContext context);
  void dispose();            // 资源释放

  // 章节上下文
  Future<Map<String, dynamic>> getContextForChapter(String chapterId);
  Future<void> onChapterSaved(String chapterId, String content);
  Future<void> onChapterCompleted(String chapterId, String content);

  // UI 构建
  Widget? buildNavigationPanel(BuildContext context);
  Widget? buildEditor(BuildContext context);
  Widget? buildInspector(BuildContext context, String entityId);

  // 链接与搜索
  Future<void> handleLink(String fromEntityId, String toEntityId, String linkType);
  Future<List<SearchResult>> search(String query);
}
```

实现类须检查 `linkType`（如仅处理 `'bound_to'`），避免创建非法链接。

### [+] ModuleRegistry 并行初始化

`initializeAll` 使用 `Future.wait` 并行调用各模块的 `initialize()`，减少启动延迟。当前仅 2 模块影响不大，随模块增长收益递增。

## 阶段规划

- **阶段1** ✅ 基础框架 + 书籍章节编辑
- **阶段2** 🔄 模块化知识库系统（大纲✅ + 角色✅，背景/灵感/物品待启动）
- **阶段3** 📋 AI 协作写作引擎（展望计划已制定）
