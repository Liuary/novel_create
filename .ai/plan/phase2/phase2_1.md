# 子阶段 2.1 — 宿主平台改造

## 状态

✅ 已完成 (2026-05-01)

## 目标

引入 SQLite/Drift、模块接口、事件总线、UI扩展槽，为知识库模块提供运行时基础设施。

## 实现清单

### Drift 数据库
- 5 张表：books, volumes, chapters, entity_links, style_profiles
- NativeDatabase 存储于用户文档目录
- build_runner 生成代码通过

### 仓储层
- BookRepository — insertOnConflictUpdate 模式（upsert）
- VolumeRepository — 按 bookId 查询/删除
- ChapterRepository — 按 volumeId 查询/删除
- EntityLinkRepository — 多条件查询（fromType+fromId / toType+toId）

### 核心抽象层
- KnowledgeModule 抽象接口（moduleId, displayName, initialize, getContextForChapter 等）
- ModuleRegistry — 注册、通知、搜索、上下文装配
- EventBus — AppEvent 发布订阅（ChapterCreated/Saved/Deleted/Completed）
- ModuleContext — 封装 DB、EventBus、LinkRepo、文件读写

### 双写机制
- BookListNotifier 所有 CRUD 方法在文件操作成功后同步写入 DB
- DB 写入为 best-effort（失败不影响文件主数据）

### UI 扩展槽
- 侧边栏底部 Tab：内容树 / 知识库
- 右侧属性面板框架（默认隐藏，为知识库模块预留）

## 文件清单

| 文件 | 说明 |
|------|------|
| `build.yaml` | Drift build_runner 配置 |
| `lib/core/database/app_database.dart` | 数据库 Schema 定义 |
| `lib/core/database/app_database.g.dart` | 自动生成 |
| `lib/core/database/database_service.dart` | 数据库服务单例 |
| `lib/core/event/event_bus.dart` | 事件总线 |
| `lib/core/module/knowledge_module.dart` | KnowledgeModule 接口 + SearchResult |
| `lib/core/module/module_context.dart` | 模块上下文 |
| `lib/core/module/module_registry.dart` | 模块注册表 |
| `lib/core/repositories/book_repository.dart` | 书籍仓储 |
| `lib/core/repositories/volume_repository.dart` | 卷仓储 |
| `lib/core/repositories/chapter_repository.dart` | 章节仓储 |
| `lib/core/repositories/entity_link_repository.dart` | 关联仓储 |
| `pubspec.yaml` (改) | 添加 drift, sqlite3_flutter_libs |
| `lib/main.dart` (改) | DatabaseService 初始化 |
| `lib/providers/app_providers.dart` (改) | 核心 providers + 双写 |
| `lib/pages/home_page.dart` (改) | 右侧属性面板 |
| `lib/widgets/sidebar.dart` (改) | Tab 切换 |

## 已知限制

- 旧 JSON 数据未自动迁移到 DB（后续子阶段处理）
- 右侧属性面板无打开入口
- KnowledgeModule 无实现模块注册
