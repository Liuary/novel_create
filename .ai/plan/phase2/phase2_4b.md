# 子阶段 2.4b — 物品模块（Item）

## 状态

🔜 待开始

## 定位

管理小说中的重要物品（法宝、丹药、信物等），追踪物品持有者变迁。

## 模块独立性

- 仅依赖 `ModuleContext` 和共享层
- 通过 `entity_links` 关联角色、地点
- 持有者信息通过 `entity_links` (holds) 和 `currentHolderId` 冗余存储

---

## 1. 功能概述

- **物品 CRUD**：名称、描述、能力、是否唯一、数量、来源
- **持有者追踪**：`currentHolderId` 直连角色 + `entity_links` 记录持有变迁历史
- **分类**：通过标签区分（法宝、丹药、信物等），使用共享 category_tags
- **列表展示**：左侧按标签分类的列表
- **上下文贡献**：当前章节中角色持有的物品

---

## 2. 数据库

使用 `items` 表（定义于 `phase2_shared.md`）。

关联通过 `entity_links`：
| link_type | from → to | 语义 |
|-----------|-----------|------|
| `holds` | character → item | 角色持有 |
| `originated_from` | item → world_entry | 物品来源地 |
| `related_to` | item → chapter | 本章提及 |

---

## 3. 文件结构

```
lib/modules/item/
  ├── item_module.dart
  ├── item_repository.dart
  ├── item_model.dart
  ├── item_providers.dart
  ├── widgets/
  │   ├── item_list.dart           # 左侧分类列表
  │   └── item_editor.dart         # 物品详情编辑器
```

---

## 4. 实施步骤

### 步骤 1：Repository 层（`item_repository.dart`）

```dart
class ItemRepository {
  Future<DbItem> create(ItemsCompanion entry);
  Future<DbItem?> getById(String id);
  Future<List<DbItem>> getAll({String? bookId});
  Future<List<DbItem>> searchByName(String query);
  Future<void> update(DbItem item);
  Future<void> delete(String id);

  // 持有者变迁（通过 entity_links）
  Future<void> updateHolder(String itemId, String? newHolderId);
  Future<List<DbEntityLink>> getHolderHistory(String itemId);
}
```

### 步骤 2：KnowledgeModule 实现

| 方法 | 实现 |
|------|------|
| `moduleId` → `"item"` |
| `displayName` → `"物品"` |
| `initialize` | 保存 context |
| `getContextForChapter(chapterId)` | 查询本章绑定的角色持有的物品 → JSON |
| `onChapterSaved` | 空 |
| `onChapterCompleted` | 空（AI 提取接口预留） |
| `buildNavigationPanel` | `ItemList`（分类筛选列表） |
| `buildEditor` | `ItemEditor`（物品详情编辑） |
| `buildInspector(entityId)` | 显示持有者 + 历史变迁 |
| `handleLink` | 处理关联请求 |
| `search` | 在 name + description + abilities + origin 中搜索 |

### 步骤 3：UI 组件

#### 3.1 物品列表（`item_list.dart`）

- 按 `category_tags` 分类筛选（使用共享 TagSelector）
- 物品名称列表 + 唯一性标记
- 搜索框
- 右键菜单：新建 / 删除

#### 3.2 物品编辑器（`item_editor.dart`）

```
名称: [____________]
描述: [____________textarea]
能力: [____________textarea]
唯一: [✓]  数量: [1]
当前持有者: [________] (只读，通过 entity_links 自动同步)
来源地: [下拉 world_entries]
来源描述: [____________]
```

---

## 5. 上下文输出格式

```json
{
  "module": "item",
  "items": [
    {
      "id": "...",
      "name": "青冥剑",
      "abilities": "斩破虚空",
      "is_unique": true,
      "holder": "凌风",
      "origin": "上古遗迹"
    }
  ]
}
```

---

## 6. 依赖清单

| 依赖 | 来源 | 状态 |
|------|------|------|
| AppDatabase (items 表) | 宿主层 | 需 schema 扩展 |
| EntityLinkRepository | ModuleContext.linkRepo | ✅ 已有 |
| EventBus | ModuleContext.eventBus | ✅ 已有 |
| TagSelector + TagService | 共享层 | 需先实现 |

---

## 7. 验证点

- [ ] 物品 CRUD 正常
- [ ] 持有者追踪（通过 entity_links 查回）
- [ ] 分类标签筛选
- [ ] 来源地关联（world_entry）可查回
- [ ] `flutter analyze` 零问题
