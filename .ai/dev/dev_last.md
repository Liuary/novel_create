# 最后操作状态 - 2026-05-01 19:20

## 分支

`master`。未提交。

## 本会话完成内容总览

### 子阶段 2.1 — 宿主平台改造
- 引入 Drift + SQLite（5 表：books/volumes/chapters/entity_links/style_profiles）
- 仓储层（BookRepo, VolumeRepo, ChapterRepo, EntityLinkRepo）
- 核心抽象层：KnowledgeModule, ModuleRegistry, EventBus, ModuleContext
- 双写机制：文件为主，DB 为索引层，CRUD 同步写入 DB
- UI 扩展槽：侧边栏 Tab（内容树/知识库）+ 右侧属性面板框架

### UX 重构
- 移除定时自动保存/保存按钮/章节切换弹窗
- 改为 1s 节流立即保存（内容变化即触发 debounce）
- 知识库分公共/私有分区
- 卷 + 按钮仅选中时显示，右键创建章节自动打开

### 搜索与替换功能
- **左侧全局搜索栏**：搜索章节名+正文，两行预览，关键词高亮，按章节距离排序，去重
- **编辑区内联搜索替换**：浮动搜索框，RenderEditable 精确高亮定位，导航切换，替换模式
- 两种高亮样式：常规匹配（淡黄 18%）、定位匹配（橙色 45%）
- 侧边栏搜索结果可联动激活内联搜索

### 文件总览

**新建 17 个文件：**
| 路径 | 用途 |
|------|------|
| `build.yaml` | Drift build_runner 配置 |
| `lib/core/database/app_database.dart` + `.g.dart` | Drift Schema（5表） |
| `lib/core/database/database_service.dart` | 数据库服务单例 |
| `lib/core/event/event_bus.dart` | 事件总线 |
| `lib/core/module/knowledge_module.dart` | 模块接口 + SearchResult |
| `lib/core/module/module_context.dart` | 模块上下文 |
| `lib/core/module/module_registry.dart` | 模块注册表 |
| `lib/core/repositories/*.dart` | 4 个仓储类 |
| `lib/widgets/search_util.dart` | 搜索工具（匹配/上下文/高亮）|
| `lib/widgets/inline_search.dart` | 内联搜索替换组件 |
| `.ai/plan/phase2/` | 阶段2计划目录 |

**修改 6 个文件：** `pubspec.yaml`, `main.dart`, `app_providers.dart`, `home_page.dart`, `sidebar.dart`, `editor_page.dart`

## 已知限制
- 旧 JSON 数据未自动迁移到 DB（首次运行空库，CRUD 逐步填充）
- 知识库模块尚无实现
- EventBus StreamController 未显式 dispose（应用级单例，可接受）
- 双写 DB 失败静默忽略（文件为主数据源）

## 下步建议
- 子阶段 2.2：大纲模块（第一个知识库模块，跑通完整链路）
- 首次迁移：扫描旧 JSON 文件填充 DB
- 搜索高亮性能优化（大文本时 painter 遍历开销）
