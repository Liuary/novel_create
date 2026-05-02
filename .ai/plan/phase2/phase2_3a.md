# 子阶段 2.3a — 角色模块（Character）

## 状态

🔜 待开始

## 定位

管理小说角色信息，追踪角色在章节中的出场和状态演变，为三期 AI 提供角色一致性检查依据。

## 模块独立性

- 仅依赖 `ModuleContext`（数据库、事件总线、关联仓储）和共享层
- 不依赖其他模块的具体实现类
- 角色与其他实体的关联通过 `entity_links` 完成

---

## 1. 功能概述

- **角色档案 CRUD**：姓名、别名、性格标签、外貌、背景故事
- **动态状态追踪**：当前位置、存活状态、持有物品
- **章节出场日志**：每章记录角色行为摘要 + 状态变化
- **角色列表**：左侧导航面板（树形按作品分组 + 标签筛选）
- **上下文贡献**：当前章节出场角色（含状态）、最近 N 章的行为日志

---

## 2. 数据库

使用 `characters` 和 `character_chapter_logs` 表（定义于 `phase2_shared.md`）。

关联通过 `entity_links`：
| link_type | from → to | 语义 |
|-----------|-----------|------|
| `appears_in` | character → chapter | 角色在章节出场 |
| `located_at` | character → world_entry | 角色位置（背景地点） |
| `featured_in` | character → outline_node | 角色参与大纲节点 |
| `holds` | character → item | 角色持有物品 |
| `related_to` | character → character | 角色间关系 |

---

## 3. 文件结构

```
lib/modules/character/
  ├── character_module.dart          # implements KnowledgeModule
  ├── character_repository.dart      # DAO（characters + character_chapter_logs）
  ├── character_model.dart           # Character 数据传输类
  ├── character_providers.dart       # Riverpod providers
  ├── widgets/
  │   ├── character_list.dart        # 左侧角色列表（分组 + 标签筛选）
  │   ├── character_editor.dart      # 中央编辑区（完整档案编辑）
  │   └── character_inspector.dart   # 右侧属性（出场章节 + 关联实体）
```

---

## 4. 实施步骤

### 步骤 1：Repository 层（`character_repository.dart`）

```dart
class CharacterRepository {
  // 角色 CRUD
  Future<DbCharacter> create(CharactersCompanion entry);
  Future<DbCharacter?> getById(String id);
  Future<List<DbCharacter>> getAll({String? bookId});
  Future<List<DbCharacter>> searchByName(String query);
  Future<void> update(DbCharacter character);
  Future<void> delete(String id);  // 级联删除日志 + entity_links

  // 章节日志
  Future<DbCharacterChapterLog> addLog(...);
  Future<List<DbCharacterChapterLog>> getLogs(String characterId);
  Future<List<DbCharacterChapterLog>> getLogsByChapter(String chapterId);
  Future<List<DbCharacterChapterLog>> getRecentLogs(String characterId, int count);
}
```

### 步骤 2：KnowledgeModule 实现

| 方法 | 实现 |
|------|------|
| `moduleId` → `"character"` |
| `displayName` → `"角色"` |
| `initialize` | 保存 context |
| `getContextForChapter(chapterId)` | 查询本章出场角色 + 最近 3 章日志 + 角色当前状态 → JSON |
| `onChapterSaved` | 空（保存不触发角色更新，待完成时 AI 提取） |
| `onChapterCompleted` | 准备 AI 提取接口（当前空实现，三期时填充） |
| `buildNavigationPanel` | `CharacterList`（列表 + 标签筛选） |
| `buildEditor` | `CharacterEditor`（完整档案编辑） |
| `buildInspector(entityId)` | 显示该角色出场章节时间线 + 关联实体 |
| `handleLink` | 处理来自章节/大纲的绑定 |
| `search` | 在 name + aliases + personality_tags + background 中搜索 |

### 步骤 3：UI 组件

#### 3.1 角色列表（`character_list.dart`）

- 按作品分组展示角色
- TabBar 标签筛选：主角 / 配角 / 反派 / 全部
- 每条显示：名称 + 存活状态图标
- 右键菜单：新建角色 / 绑定到当前章节
- 搜索框过滤角色名称

#### 3.2 角色编辑器（`character_editor.dart`）

表单布局：
```
姓名: [____________]
别名: [____________]
性格标签: [TagSelector 多选]   ← 使用共享 TagSelector
外貌: [____________textarea]
背景故事: [____________textarea]
当前状态: [____________]
当前位置: [下拉选择地点]        ← 通过 entity_links 查 world_entries
存活: [✓]
```

#### 3.3 角色属性面板（`character_inspector.dart`）

- 章节出场时间线（按时间倒序的 chapter_logs 列表）
- 手动添加/编辑出场日志
- 显示关联实体（当前位置地点、持有物品等）

---

## 5. 上下文输出格式

```json
{
  "module": "character",
  "appearing_characters": [
    {
      "id": "...",
      "name": "凌风",
      "current_status": "正在宗门修炼",
      "location": "青云宗",
      "recent_logs": [
        {"chapter": "第3章", "summary": "击败守门弟子…"},
        {"chapter": "第2章", "summary": "初入宗门…"}
      ],
      "personality_tags": ["冷静", "坚毅"],
      "is_dead": false
    }
  ]
}
```

---

## 6. 依赖清单

| 依赖 | 来源 | 状态 |
|------|------|------|
| AppDatabase (characters, character_chapter_logs 表) | 宿主层 | 需 schema 扩展 |
| EntityLinkRepository | ModuleContext.linkRepo | ✅ 已有 |
| EventBus | ModuleContext.eventBus | ✅ 已有 |
| TagSelector（标签选择组件） | 共享 UI | 需先实现 |
| TagService（标签服务） | 共享服务 | 需先实现 |
| 背景模块 (world_entries) | ❌ 不依赖 | 通过 entity_links 松散关联 |

---

## 7. 验证点

- [ ] 角色 CRUD 正常
- [ ] 章节出场日志增删
- [ ] 标签筛选功能
- [ ] getContextForChapter 返回本章出场角色
- [ ] 通过 entity_links 关联到地点（world_entry）可正常查回
- [ ] `flutter analyze` 零问题
