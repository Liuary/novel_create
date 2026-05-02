# 子阶段 2.4a — 灵感模块（Inspiration）

## 状态

🔜 待开始

## 定位

管理创作灵感碎片（主题走向、核心梗概、具体桥段/点子），作为创意来源库。

## 模块独立性

- 最独立的模块，无外部实体依赖
- 仅使用 `entity_links` 自由关联任意实体

---

## 1. 功能概述

- **三级灵感**：平台级（世界观/主题）、架构级（故事梗概）、碎片级（桥段/点子）
- **卡片网格展示**：视觉化浏览灵感，支持拖拽卡片到章节/大纲节点建立关联
- **来源标记**：user（手动录入）/ ai（AI 生成）
- **上下文贡献**：平台+架构级全部灵感 + 绑定当前章节的碎片级灵感

---

## 2. 数据库

使用 `inspirations` 表（定义于 `phase2_shared.md`）。

关联通过 `entity_links`：
- `from_type: 'inspiration'`, `to_type: '*'`, `link_type: 'related_to'`

---

## 3. 文件结构

```
lib/modules/inspiration/
  ├── inspiration_module.dart
  ├── inspiration_repository.dart
  ├── inspiration_model.dart
  ├── inspiration_providers.dart
  ├── widgets/
  │   ├── card_grid.dart          # 左侧卡片网格（按层级分组）
  │   └── card_editor.dart        # 卡片详情编辑器
```

---

## 4. 实施步骤

### 步骤 1：Repository 层（`inspiration_repository.dart`）

```dart
class InspirationRepository {
  Future<DbInspiration> create(InspirationsCompanion entry);
  Future<DbInspiration?> getById(String id);
  Future<List<DbInspiration>> getAll({String? bookId});
  Future<List<DbInspiration>> getByLevel(String level, {String? bookId});
  Future<List<DbInspiration>> searchByKeyword(String query);
  Future<void> update(DbInspiration inspiration);
  Future<void> delete(String id);
}
```

### 步骤 2：KnowledgeModule 实现

| 方法 | 实现 |
|------|------|
| `moduleId` → `"inspiration"` |
| `displayName` → `"灵感"` |
| `initialize` | 保存 context |
| `getContextForChapter(chapterId)` | 返回平台级+架构级全部 + 绑定本章的碎片级 → JSON |
| `onChapterSaved` | 空 |
| `onChapterCompleted` | 空 |
| `buildNavigationPanel` | `CardGrid`（三级分组卡片网格） |
| `buildEditor` | `CardEditor`（卡片读写） |
| `buildInspector(entityId)` | 显示该灵感关联的实体列表 |
| `handleLink` | 接收外部实体的关联请求 |
| `search` | 在 title + content 中搜索 |

### 步骤 3：UI 组件

#### 3.1 卡片网格（`card_grid.dart`）

- 三列分组：平台级 | 架构级 | 碎片级
- 每列标题 + 可滚动的卡片列表
- 卡片显示：标题（3行截断）+ 来源图标（user/ai）
- 点击卡片 → 打开编辑器
- 拖拽卡片到侧边栏章节 → 创建 entity_links

#### 3.2 卡片编辑器（`card_editor.dart`）

- 标题输入框
- 内容多行文本区
- 层级选择下拉
- 来源标记（可切换）

---

## 5. 上下文输出格式

```json
{
  "module": "inspiration",
  "platform": [
    {"title": "主题：废柴逆袭", "content": "..."}
  ],
  "architectural": [
    {"title": "三幕式结构：崛起-低谷-巅峰", "content": "..."}
  ],
  "bound_fragments": [
    {"title": "第5章 初遇女主 点子", "content": "..."}
  ]
}
```

---

## 6. 依赖清单

| 依赖 | 来源 | 状态 |
|------|------|------|
| AppDatabase (inspirations 表) | 宿主层 | 需 schema 扩展 |
| EntityLinkRepository | ModuleContext.linkRepo | ✅ 已有 |
| EventBus | ModuleContext.eventBus | ✅ 已有 |
| CardGrid（卡片组件） | 共享 UI | 需先实现 |

---

## 7. 验证点

- [ ] 灵感 CRUD 正常
- [ ] 三级分组展示正确
- [ ] 卡片拖拽到章节创建关联
- [ ] 搜索返回匹配灵感
- [ ] `flutter analyze` 零问题
