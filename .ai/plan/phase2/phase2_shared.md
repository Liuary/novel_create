# 阶段2 共享基础设施 & 模块间契约

## 状态

🔧 待实施（需在任一模块开发前完成 schema 扩展）

---

## 1. 模块隔离原则

```
┌──────────────────────────────────────────────────────┐
│  宿主层 (lib/core/)                                   │
│  ┌─────────────┐ ┌──────────┐ ┌────────────────────┐ │
│  │ AppDatabase  │ │ EventBus │ │ EntityLinkRepository│ │
│  │ (所有表)     │ │          │ │                    │ │
│  └──────┬───────┘ └────┬─────┘ └─────────┬──────────┘ │
│  ┌──────┴──────────────┴─────────────────┴──────────┐ │
│  │              ModuleContext                        │ │
│  └──────┬───────────────────────────────────────────┘ │
│  ┌──────┴──────┐ ┌────────────┐ ┌─────────────────┐  │
│  │ TagService  │ │ TreeUtils  │ │ Shared Widgets  │  │
│  │(category_tags)│(通用树操作)│ │(树/卡片/标签)    │  │
│  └──────┬──────┘ └──────┬─────┘ └────────┬────────┘  │
└─────────┼───────────────┼────────────────┼───────────┘
          │               │                │
    ┌─────┴─────┐  ┌──────┴──────┐  ┌─────┴─────┐
    │ 大纲模块   │  │  角色模块   │  │ 背景模块   │  ...
    │ moduleId: │  │ moduleId:  │  │ moduleId: │
    │ "outline" │  │ "character"│  │ "world"  │
    └───────────┘  └────────────┘  └──────────┘

模块之间：只通过 entity_links (from_type/to_type 字符串) + 
          KnowledgeModule 接口间接交互，禁止直接 import
```

---

## 2. 数据库 Schema 扩展（`app_database.dart`）

**2.1 已完成后需新增以下表：**

### category_tags（通用标签，多模块共用）

```dart
@DataClassName('DbCategoryTag')
class CategoryTags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();          // 树形结构
  TextColumn get moduleId => text().withDefault(const Constant(''))(); // 留空=全局共享
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

使用方式：
- `moduleId` = `""` → 全局标签（预设：修炼体系、地理、势力、主角、配角等）
- `moduleId` = `"character"` → 角色专用标签
- `moduleId` = `"world"` → 背景设定专用标签

### outline_nodes（大纲模块）

```dart
@DataClassName('DbOutlineNode')
class OutlineNodes extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();              // null=公共知识库
  TextColumn get parentId => text().nullable()();            // 树形结构
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get expectedWordCount => integer().withDefault(const Constant(0))();
  TextColumn get type => text().withDefault(const Constant('free'))();
    // main_arc / sub_arc / scene / free
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('planning'))();
    // planning / writing / done
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### characters（角色模块）

```dart
@DataClassName('DbCharacter')
class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get aliases => text().withDefault(const Constant(''))();
  TextColumn get personalityTags => text().withDefault(const Constant(''))(); // 逗号分隔标签
  TextColumn get appearance => text().withDefault(const Constant(''))();
  TextColumn get background => text().withDefault(const Constant(''))();
  TextColumn get currentStatus => text().withDefault(const Constant(''))();
  TextColumn get locationId => text().nullable()();          // → world_entries.id
  BoolColumn get isDead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### character_chapter_logs（角色章节行为日志）

```dart
@DataClassName('DbCharacterChapterLog')
class CharacterChapterLogs extends Table {
  TextColumn get id => text()();
  TextColumn get characterId => text()();
  TextColumn get chapterId => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get statusChangedFrom => text().withDefault(const Constant(''))();
  TextColumn get statusChangedTo => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### world_entries（背景设定）

```dart
@DataClassName('DbWorldEntry')
class WorldEntries extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get categoryTagId => text().nullable()();       // → category_tags.id
  TextColumn get flexibleJson => text().withDefault(const Constant('{}'))(); // 分类特有字段
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### inspirations（灵感模块）

```dart
@DataClassName('DbInspiration')
class Inspirations extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get level => text()();                           // platform / architectural / fragment
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('user'))(); // user / ai
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

### items（物品模块）

```dart
@DataClassName('DbItem')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get abilities => text().withDefault(const Constant(''))();
  BoolColumn get isUnique => boolean().withDefault(const Constant(false))();
  TextColumn get currentHolderId => text().nullable()();     // → characters.id
  TextColumn get location => text().withDefault(const Constant(''))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get origin => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 表注册（更新 AppDatabase）

```dart
@DriftDatabase(tables: [
  Books, Volumes, Chapters, EntityLinks, StyleProfiles,
  CategoryTags,          // 共享
  OutlineNodes,           // 大纲
  Characters, CharacterChapterLogs, // 角色
  WorldEntries,           // 背景
  Inspirations,           // 灵感
  Items,                  // 物品
])
```

**⚠ 注意**：一次性添加所有表后需运行 `dart run build_runner build` 重新生成 `.g.dart`。schemaVersion 升级到 2。

---

## 3. 共享工具与组件

### 3.1 TagService（`lib/core/services/tag_service.dart`）

```dart
class TagService {
  final AppDatabase _db;
  // CRUD + 树形查询 + 按 moduleId 过滤
  Future<List<DbCategoryTag>> getByModule(String moduleId);
  Future<List<DbCategoryTag>> getGlobal();
  Future<List<DbCategoryTag>> getChildren(String parentId);
  // ... 树形遍历
}
```

### 3.2 TreeUtils（`lib/core/utils/tree_utils.dart`）

通用树形操作函数集（不依赖任何模块）：
- `flattenTree(node, children)` — 展平为排序列表
- `getAncestors(node, children)` — 获取祖先路径
- `reorderNodes(parentId, oldIndex, newIndex)` — 重排序
- `buildTreeMap(items)` — 按 parentId 分组

### 3.3 共享 UI 组件（`lib/widgets/knowledge/`）

| 组件 | 用途 | 依赖 |
|------|------|------|
| `TreeNavPanel` | 通用树形导航（展开/折叠/右键/拖拽） | TreeUtils |
| `TreeDragTarget` | 拖拽放置目标（绑定章节/大纲） | entity_links |
| `CardGrid` | 卡片网格（灵感/物品列表） | 无 |
| `TagSelector` | 多选标签选择器 | TagService |
| `EntityLinkPanel` | 显示/管理关联实体 | EntityLinkRepository |
| `DynamicForm` | 根据 JSON schema 渲染表单（背景模块） | 无 |

---

## 4. 模块间关联约定（entity_links）

| from_type | to_type | link_type | 含义 | 备注 |
|-----------|---------|-----------|------|------|
| `chapter` | `outline_node` | `bound_to` | 章节绑定大纲节点 | 多对多 |
| `character` | `chapter` | `appears_in` | 角色在某章出场 | 可加 metadata（重要性等）|
| `character` | `world_entry` | `located_at` | 角色当前位置 |
| `character` | `outline_node` | `featured_in` | 角色参与大纲节点 |
| `character` | `item` | `holds` | 角色持有物品 |
| `item` | `world_entry` | `originated_from` | 物品来源地点 |
| `world_entry` | `character` | `ruled_by` | 势力领袖 |
| `inspiration` | `*` | `related_to` | 灵感关联任意实体 | 自由关联 |
| `character` | `character` | `related_to` | 角色间关系 | metadata 存储关系描述 |

**规则**：
- 模块仅通过 `from_type`/`to_type` 字符串识别实体归属
- 模块删除实体时需级联删除相关 entity_links
- `EntityLinkRepository` 在 ModuleContext 中暴露，模块直接调用

---

## 5. 目录约定

```
lib/
├── core/                          # 宿主层（已存在）
│   ├── database/                  # Schema + DAO 基础
│   ├── event/                     # 事件总线
│   ├── module/                    # KnowledgeModule + ModuleContext + ModuleRegistry
│   ├── repositories/              # 通用仓储
│   ├── services/                  # TagService 等共享服务
│   └── utils/                     # TreeUtils 等工具
├── modules/                       # 知识库模块（新建）
│   ├── outline/                   # 大纲模块
│   ├── character/                 # 角色模块
│   ├── worldbuilding/             # 背景设定模块
│   ├── inspiration/               # 灵感模块
│   └── item/                      # 物品模块
├── widgets/
│   └── knowledge/                 # 共享 UI 组件（新建）
│       ├── tree_nav_panel.dart
│       ├── card_grid.dart
│       ├── tag_selector.dart
│       ├── entity_link_panel.dart
│       └── dynamic_form.dart
└── providers/
    └── (模块 providers 在各模块内定义)
```

---

## 6. 实施顺序建议

```
  2.1 宿主改造 ✅
   │
   ├── 共享层补充（Schema 扩展 + TagService + TreeUtils + 共享 UI）
   │      ↓
   ├── 2.2 大纲模块 ──────────── 第一个完整样板
   │      ↓
   ├── 2.3a 角色模块 ──┐
   │      ↓             ├── 可并行（依赖共享层 + entity_links）
   ├── 2.3b 背景模块 ──┘
   │      ↓
   ├── 2.4a 灵感模块 ──┐
   │      ↓             ├── 可并行（最独立）
   ├── 2.4b 物品模块 ──┘
   │
   └── 2.5 打磨与三期预制
```

**共享层实施量**：约 4 个新文件 + 1 个文件修改（app_database.dart），是后续并行的前提。
