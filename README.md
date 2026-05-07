# Novel Create — 小说创作工作站

基于 Flutter 的 PC 端小说创作工具，提供章节管理、知识库模块化系统，以及后续规划的 AI 协作创作引擎。

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.x (Dart SDK ^3.11.5) |
| 状态管理 | [flutter_riverpod](https://riverpod.dev/) |
| 数据存储 | SQLite ([drift](https://drift.simonbinder.eu/)) + JSON 文件（正文） |
| 编辑器 | 原生 TextField，写作/阅读双模式，实时标注（下划线/删除线/高亮） |
| AI 接入 | OpenAI 兼容 API（阶段3 规划） |
| 开发环境 | VS Code + [Kilo](https://kilo.ai) AI 编程助手 |
| AI 模型 | DeepSeek V4 Pro Max（设计+开发）、GLM 5.1（代码审阅） |
| Agent 工作流 | [AI_Prompt](https://github.com/Liuary/AI_Prompt) Agent 工作流框架 |
| 测试 | flutter_test + flutter_lints |

## 快速开始

```bash
# 安装依赖
flutter pub get

# 生成 Drift 数据库代码
dart run build_runner build

# 运行
flutter run -d windows

# 静态检查
flutter analyze

# 测试
flutter test
```

## 项目结构

```
lib/
├── core/                   # 核心基础设施
│   ├── database/           # Drift 数据库定义 + DAO
│   ├── event/              # 事件总线（阶段3 使用）
│   ├── module/             # 知识库模块接口 (KnowledgeModule) + 注册中心 (ModuleRegistry)
│   ├── repositories/       # 书籍/卷/章 数据仓储层
│   └── utils/              # 工具函数
├── models/                 # 数据模型 (Chapter, Annotation, UserConfig 等)
├── modules/                # 知识库模块
│   ├── modules.dart        # 模块聚合注册入口
│   ├── outline/            # 大纲模块（树形结构 + 可视化预览 + 拖拽排序）
│   └── character/          # 角色模块（CRUD + 章节出场日志）
├── pages/                  # 页面入口
├── providers/              # Riverpod 状态提供者
├── services/               # 业务服务（存储、提示）
├── utils/                  # 公共工具（render_utils 等）
└── widgets/                # UI 组件
    ├── editor/             # 编辑器组件（标注绘制器、文本控制器）
    ├── knowledge/          # 知识库通用组件（TreeNavPanel）
    └── sidebar/            # 侧边栏组件（书籍/卷/章树、知识库面板）
```

## 功能概览

### 已完成（阶段1 + 阶段2 部分）

- **书籍章节管理**：多书籍、卷章树、拖拽排序、搜索跳转、F2 快捷重命名
- **双模式编辑器**：写作模式（编辑正文）+ 阅读模式（标注查看），实时字数统计
- **标注系统**：下划线、删除线、高亮，颜色可配置，自动保存
- **大纲模块**：树形节点管理、类型/状态标记、拖拽排序、可视化分支预览
- **角色模块**：角色信息编辑、性格标签、别名、当前状态、章节出场日志
- **知识库面板**：模块化切换，公共/私有知识库分离

### 开发中

- 背景设定模块（世界观/地点/势力/历史事件）
- 灵感模块（随手记录、社区标签归类）
- 物品模块（道具/装备/关键物品）
- 模块间关联系统（角色↔章节、大纲节点↔章节 等）

### 计划中（阶段3）

- AI 协作写作引擎（多 AI 并行创作、交叉审阅）
- 自动知识库更新（AI 从正文提取角色/地点/事件信息）
- 剧情一致性检查（前后矛盾检测）

## 设计原则

- **PC 优先**：侧边栏 + 内容区双栏布局，支持键鼠快捷操作
- **自动保存**：键盘输入实时保存，最低 1 秒节流间隔，无手动保存按钮
- **模块化**：知识库模块通过 `KnowledgeModule` 接口接入，`modules.dart` 统一注册，不硬编码
- **双重存储**：正文使用 JSON 文件存储，元数据和关联使用 SQLite
- **代码规范**：标识符英文，注释中文；`flutter analyze` 零问题方可提交

## 开发进度

| 阶段 | 状态 | 说明 |
|------|------|------|
| 阶段1 — 基础框架 | ✅ 完成 | 书籍章节编辑、侧边栏、编辑器核心 |
| 阶段2.1 — 宿主改造 | ✅ 完成 | 知识库 Tab、模块注册、Sidebar 改造 |
| 阶段2.2 — 大纲模块 | ✅ 完成 | 树形导航、编辑器、可视化预览、拖拽 |
| 阶段2.3a — 角色模块 | ✅ 完成 | CRUD、章节日志、搜索 |
| 阶段2.3b — 背景设定 | 🔜 待启动 | 世界观/地点/势力/事件 |
| 阶段2.4a — 灵感模块 | 🔜 待启动 | 灵感笔记、社区归类 |
| 阶段2.4b — 物品模块 | 🔜 待启动 | 道具/装备/关键物品 |
| 阶段3 — AI 协作引擎 | 📋 计划中 | 多AI创作、审阅、知识库自更新 |
