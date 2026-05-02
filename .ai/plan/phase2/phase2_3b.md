# 子阶段 2.3b — 背景设定模块（Worldbuilding）

## 状态

🔜 待开始

## 定位

管理小说的世界观设定（地理、势力、修炼体系、历史事件等），为三期 AI 提供世界观一致性上下文。

## 模块独立性

- 仅依赖 `ModuleContext` 和共享层（TagService、标签树组件）
- 通过 `entity_links` 与其他模块关联
- 不同时依赖角色模块或其他模块

---

## 1. 功能概述

- **标签树管理**：用标签树代替固定分类（修炼体系、地理、势力等），用户可自定义
- **条目 CRUD**：名称、描述、分类标签、动态自定义字段
- **左侧标签筛选**：点击标签过滤条目列表
- **动态表单**：根据选择的不同分类标签，动态渲染不同字段
- **上下文贡献**：当前章节涉及的地点/势力/规则等

---

## 2. 数据库

使用 `world_entries` 表（定义于 `phase2_shared.md`）。

`category_tags` 表已在共享层，`moduleId` 为 `"world"` 时归属本模块。

关联通过 `entity_links`：
| link_type | from → to | 语义 |
|-----------|-----------|------|
| `located_at` | character → world_entry | 角色位于此 |
| `originated_from` | item → world_entry | 物品来源地 |
| `ruled_by` | world_entry → character | 势力领袖 |
| `related_to` | world_entry → chapter | 本章涉及此设定 |

---

## 3. 文件结构

```
lib/modules/worldbuilding/
  ├── worldbuilding_module.dart      # implements KnowledgeModule
  ├── worldbuilding_repository.dart  # DAO（world_entries + category_tags 读）
  ├── world_entry_model.dart         # WorldEntry 数据传输类
  ├── worldbuilding_providers.dart   # Riverpod providers
  ├── widgets/
  │   ├── tag_sidebar.dart           # 左侧标签树筛选
  │   ├── entry_list.dart            # 中间条目列表
  │   └── entry_editor.dart          # 右侧/中央动态表单编辑器
```

---

## 4. 实施步骤

### 步骤 1：Repository 层（`worldbuilding_repository.dart`）

```dart
class WorldbuildingRepository {
  // 条目 CRUD
  Future<DbWorldEntry> create(WorldEntriesCompanion entry);
  Future<DbWorldEntry?> getById(String id);
  Future<List<DbWorldEntry>> getAll({String? bookId});
  Future<List<DbWorldEntry>> getByCategory(String categoryTagId);
  Future<List<DbWorldEntry>> searchByName(String query);
  Future<void> update(DbWorldEntry entry);
  Future<void> delete(String id);  // 级联删除 entity_links
}
```

### 步骤 2：KnowledgeModule 实现

| 方法 | 实现 |
|------|------|
| `moduleId` → `"world"` |
| `displayName` → `"背景设定"` |
| `initialize` | 保存 context，预置默认标签（修炼体系、地理、势力等） |
| `getContextForChapter(chapterId)` | 查询该章涉及的设定条目（通过 entity_links）→ JSON |
| `onChapterSaved` | 空 |
| `onChapterCompleted` | 空（AI 提取接口预留） |
| `buildNavigationPanel` | `TagSidebar`（标签树筛选） + `EntryList`（条目列表） |
| `buildEditor` | `EntryEditor`（动态表单） |
| `buildInspector(entityId)` | 显示关联实体（在此地点的角色、来源此地的物品等） |
| `handleLink` | 处理跨模块关联 |
| `search` | 在 name + description + flexibleJson 中搜索 |

### 步骤 3：UI 组件

#### 3.1 标签侧边栏（`tag_sidebar.dart`）

- 树形标签列表（基于共享 `TreeNavPanel`）
- 预设标签树：
  ```
  背景设定
  ├── 修炼体系
  │   ├── 境界等级
  │   └── 功法体系
  ├── 地理
  │   ├── 大陆
  │   ├── 城镇
  │   └── 禁地
  ├── 势力
  │   ├── 宗门
  │   ├── 家族
  │   └── 帝国
  ├── 历史事件
  └── 特殊规则
  ```
- 右键菜单：新建子标签 / 重命名 / 删除
- 点击标签 → 右侧条目列表过滤

#### 3.2 条目列表（`entry_list.dart`）

- 简洁列表（名称 + 简短描述预览）
- 搜索框过滤
- 新建按钮

#### 3.3 动态表单编辑器（`entry_editor.dart`）

- 名称、描述（基础字段）
- 根据 `category_tag_id` 动态渲染分类特有字段：
  - 选择"地理" → 显示：气候、面积、统治者、特征
  - 选择"势力" → 显示：类型、领袖、成员数、领地名
  - 选择"修炼体系" → 显示：境界列表、突破条件
- 字段定义预置在 JSON 配置中（`flexibleJson` 存储）

**字段配置示例**（存放在模块代码中，非数据库）：
```dart
const _fieldConfigs = {
  'geography': ['climate', 'area', 'ruler', 'characteristics'],
  'faction': ['type', 'leader', 'memberCount', 'territory'],
  'cultivation': ['realmHierarchy', 'breakthroughCondition'],
};
```

通过标签名称映射到上述配置。`flexibleJson` 存储用户填写的值。

---

## 5. 上下文输出格式

```json
{
  "module": "world",
  "relevant_entries": [
    {
      "id": "...",
      "name": "青云宗",
      "description": "正道七宗之首，位于青云山巅…",
      "category": "势力.宗门",
      "fields": {
        "type": "宗门",
        "leader": "青云真人",
        "territory": "青云山脉"
      }
    }
  ]
}
```

---

## 6. 依赖清单

| 依赖 | 来源 | 状态 |
|------|------|------|
| AppDatabase (world_entries, category_tags 表) | 宿主层 | 需 schema 扩展 |
| EntityLinkRepository | ModuleContext.linkRepo | ✅ 已有 |
| EventBus | ModuleContext.eventBus | ✅ 已有 |
| TagService | 共享服务 | 需先实现 |
| TreeNavPanel | 共享 UI | 需先实现 |
| DynamicForm | 共享 UI | 需先实现 |

---

## 7. 验证点

- [ ] 标签树 CRUD 正常
- [ ] 条目 CRUD 正常，分类筛选正确
- [ ] 动态表单根据标签显示不同字段
- [ ] flexibleJson 正确存取
- [ ] entity_links 关联（角色-地点、物品-来源）可查回
- [ ] `flutter analyze` 零问题
