# 子阶段 2.2 — 大纲模块（Outline）

## 状态

🔜 待开始

## 定位

第一个完整知识库模块样板，跑通：Schema 扩展 → Repository → KnowledgeModule 实现 → UI 注册 → 上下文装配 → 搜索 的完整链路。

---

## 1. 功能概述

- **树形结构**：主线 → 支线 → 细纲 → 场景，自由嵌套
- **节点绑定章节**：章节可关联多个大纲节点（多对多，通过 `entity_links`）
- **拖拽排序 + 嵌套**：节点在树内拖拽排序、改变层级
- **看板视图**（可选）：按状态（planning/writing/done）分栏展示节点卡片
- **上下文贡献**：章节绑定的节点 + 祖先路径 + 节点上的角色/物品标记

---

## 2. 数据库

使用 `outline_nodes` 表（已定义于 `phase2_shared.md`）。

关联通过 `entity_links`：
- `from_type: 'chapter'`, `to_type: 'outline_node'`, `link_type: 'bound_to'`

---

## 3. 文件结构

```
lib/modules/outline/
  ├── outline_module.dart            # implements KnowledgeModule
  ├── outline_repository.dart        # DAO（OutlineNodes 表 CRUD）
  ├── outline_node_model.dart        # OutlineNode 数据传输类
  ├── widgets/
  │   ├── outline_tree_nav.dart      # 左侧树形导航面板
  │   ├── outline_node_editor.dart   # 中央编辑区（节点详情编辑）
  │   └── outline_inspector.dart     # 右侧属性面板（绑定章节列表等）
  └── outline_providers.dart         # Riverpod providers（模块内部）
```

---

## 4. 实施步骤

### 步骤 1：Repository 层

**文件**：`outline_repository.dart`

```dart
class OutlineRepository {
  final AppDatabase _db;

  // 增删改查
  Future<DbOutlineNode> create(OutlineNodesCompanion entry);
  Future<DbOutlineNode?> getById(String id);
  Future<List<DbOutlineNode>> getAll({String? bookId});  // bookId=null=公共
  Future<List<DbOutlineNode>> getChildren(String parentId);
  Future<List<DbOutlineNode>> getRoots({String? bookId});
  Future<void> update(DbOutlineNode node);
  Future<void> delete(String id);  // 级联删除子节点 + entity_links
  Future<void> updateSortOrder(String id, int newOrder);
  Future<void> moveNode(String id, String newParentId, int newOrder);
}
```

### 步骤 2：数据模型

**文件**：`outline_node_model.dart`

```dart
class OutlineNode {
  final String id;
  final String? bookId;
  final String? parentId;
  final String title;
  final String description;
  final int expectedWordCount;
  final OutlineNodeType type;   // mainArc / subArc / scene / free
  final int sortOrder;
  final OutlineNodeStatus status; // planning / writing / done
  final List<OutlineNode> children; // 运行时填充，非 DB 字段
}
```

### 步骤 3：KnowledgeModule 实现

**文件**：`outline_module.dart`

核心方法实现：
| 方法 | 实现 |
|------|------|
| `moduleId` → `"outline"` |
| `displayName` → `"大纲"` |
| `initialize(ModuleContext)` | 保存 context 引用 |
| `getContextForChapter(chapterId)` | 查询该章绑定的节点 + 祖先路径 → JSON |
| `onChapterSaved` | 空实现（大纲模块不响应保存） |
| `onChapterCompleted` | 自动标记绑定的节点状态为 `done` |
| `buildNavigationPanel` | 返回 `OutlineTreeNav`（树形导航） |
| `buildEditor` | 返回 `OutlineNodeEditor`（节点详情编辑） |
| `buildInspector(entityId)` | 返回 `OutlineInspector`（关联章节/角色列表） |
| `handleLink` | 处理从章节拖拽来的绑定请求 |
| `search` | 在 `outline_nodes.title` 和 `description` 中搜索 |

### 步骤 4：UI 组件

#### 4.1 树形导航面板（`outline_tree_nav.dart`）

- 基于 `TreeNavPanel` 共享组件（需要先实现共享组件）
- 功能：展开/折叠、右键菜单（新建子节点/重命名/删除/绑定到当前章节）
- 排序：同层级内按 `sortOrder` 排列
- 拖拽：节点可拖拽排序和改变父节点

#### 4.2 节点编辑器（`outline_node_editor.dart`）

- 显示选中节点的完整信息
- 字段：标题、描述（多行）、类型下拉、预估字数
- 状态切换：planning → writing → done（下拉或按钮组）
- 绑定摘要：显示该节点已绑定的全部章节列表
- 关联摘要：显示该节点关联的角色、物品（通过 entity_links 查询）

#### 4.3 属性面板（`outline_inspector.dart`）

- 显示当前选中实体的节点概要
- 绑定操作：列出所有大纲节点，勾选/取消关联
- 当选中一个 chapter entityId 时，显示该章已绑定的大纲节点

### 步骤 5：看板视图（可选，低优先级）

- 以三列（planning / writing / done）展示节点卡片
- 可拖拽卡片改变状态

### 步骤 6：模块注册

在 `main.dart` 中注册：
```dart
final outlineModule = OutlineModule();
ModuleRegistry.instance.register(outlineModule);
```

---

## 5. 上下文输出格式（getContextForChapter）

```json
{
  "module": "outline",
  "nodes": [
    {
      "id": "...",
      "title": "主线 - 主角入宗门",
      "type": "main_arc",
      "status": "writing",
      "description": "...",
      "ancestors": ["卷一", "主线"],
      "expectedWordCount": 5000
    }
  ]
}
```

---

## 6. 搜索实现

```dart
Future<List<SearchResult>> search(String query) async {
  final nodes = await _repo.searchByKeyword(query);
  return nodes.map((n) => SearchResult(
    moduleId: moduleId,
    entityId: n.id,
    title: n.title,
    snippet: n.description.length > 80 
        ? '${n.description.substring(0, 80)}...' 
        : n.description,
    entityType: 'outline_node',
  )).toList();
}
```

---

## 7. 依赖清单

| 依赖 | 来源 | 状态 |
|------|------|------|
| AppDatabase (outline_nodes 表) | 宿主层 | 需 schema 扩展 |
| EntityLinkRepository | ModuleContext.linkRepo | ✅ 已有 |
| EventBus | ModuleContext.eventBus | ✅ 已有 |
| TreeNavPanel（树形组件） | 共享 UI | 需先实现 |
| TreeUtils | 共享工具 | 需先实现 |
| TagService | 共享服务 | 不需（大纲不用标签） |

---

## 8. 验证点

- [ ] 大纲树 CRUD 正常
- [ ] 拖拽排序/嵌套后顺序持久化
- [ ] 章节绑定/解绑大纲节点
- [ ] getContextForChapter 返回正确上下文
- [ ] onChapterCompleted 自动标记节点完成
- [ ] 搜索返回匹配节点
- [ ] `flutter analyze` 零问题
