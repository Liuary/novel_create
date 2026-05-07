# 代码模式与项目约定

> 来源：第三轮全项目代码审查（2026-05-07）
> 最后更新：2026-05-07

## 数据模型

### [+] copyWith 哨兵值模式

**场景**：模型字段为可空类型，`copyWith` 需要区分"调用方未传入该参数"和"调用方显式传入 null"。

**错误写法**（`??` 会吞掉 null）：
```dart
OutlineNode copyWith({String? parentId}) {
  return OutlineNode(parentId: parentId ?? this.parentId); // null 无法传递
}
```

**正确写法**（哨兵值）：
```dart
static const _sentinel = Object();

OutlineNode copyWith({Object? parentId = _sentinel}) {
  return OutlineNode(
    parentId: identical(parentId, _sentinel) ? this.parentId : parentId as String?,
  );
}
```

适用场景：任何模型的可空字段且需要通过 `copyWith` 清空为 null 时。

### [+] 逗号分隔字段统一使用 List<String>

项目中 `personalityTagsList` 使用 `List<String>` 通过 `join(',')` / `split(',')` 序列化。同类多值字段（如 aliases）应保持此模式，避免部分用 String 部分用 List<String> 造成 API 不一致。

## 数据库操作

### [+] Drift 异步方法必须 await，不可 fire-and-forget

所有 `ref.read(xxxRepo).upsert(...)` / `.delete(...)` 等返回 Future 的 Drift 方法，必须 `await`。禁止使用 `unawaited()` 或直接丢弃 Future：

- `unawaited()` 使 try-catch 完全失效（异步异常走微任务队列，不被同步 catch 捕获）
- 调用方无法感知 DB 操作失败，数据可能处于不一致状态
- 替代方案：确实无需等待时，应使用 `unawaited()` 但仍需在内部方法中有独立的错误处理

### [+] Repository 接口语义统一

同类型 Repository 的方法语义必须一致。例如 `getAll({String? bookId})`：
- `bookId == null` 时应返回全部数据（不加过滤），而非过滤 `bookId.isNull()`（仅返回孤立记录）
- 各 Repository 实现须对齐此语义

### [+] 删除操作包裹事务

涉及多表操作的 `delete()` 应使用 `_db.transaction()` 包裹，确保级联删除的原子性：
```dart
Future<void> delete(String id) async {
  await _db.transaction(() async {
    await (_db.delete(_db.xxx)..where((t) => t.id.equals(id))).go();
    // 级联删除关联数据
  });
}
```

### [+] EntityLink 去重检查

`EntityLinkRepository.create()` 应在插入前查询是否存在相同的 `(fromType, fromId, toType, toId, linkType)` 5 元组：
```dart
final existing = await _db.select(_db.entityLinks)
  ..where((t) => t.fromType.equals(fromType))
  // ... 5 个条件
  .getSingleOrNull();
if (existing != null) return existing;
```

## 状态管理

### [+] 响应书籍切换：ref.listen 驱动副作用

`ConsumerStatefulWidget` 中需要监听 provider 变化并触发数据加载时，使用 `ref.listen` 而非 `ref.watch`：
```dart
@override
Widget build(BuildContext context) {
  ref.listen<String?>(currentBookIdProvider, (prev, next) {
    if (prev != next) _load();
  });
  // ...
}
```
`ref.watch` 用于重建 UI，`ref.listen` 用于驱动副作用（如数据加载）。

### [+] ModuleRegistry 并行初始化

模块间无依赖时，使用 `Future.wait` 并行初始化减少启动延迟：
```dart
Future<void> initializeAll(ModuleContext context) async {
  await Future.wait(_modules.map((m) => m.initialize(context)));
}
```

## 错误处理

### [+] catch 块必须记录日志

禁止 `catch (_) {}` 静默吞异常。至少使用 `catch (e) { debugPrint('描述: $e'); }`。

### [+] UI 异步回调必须检查 mounted

所有涉及 StatefulWidget 的 async 回调，在 `await` 后访问 `widget` / `context` / 调用 `setState` 前，必须检查 `mounted`：
```dart
Future<void> _save() async {
  await repo.update(data);
  if (!mounted) return;  // 必须在访问 widget 前检查
  widget.onChanged(data);
}
```

## 代码组织

### [+] 单文件不超过 200 行（含 5 个以上独立模块时拆分）

当前超标文件：`editor_page.dart`(925), `outline_module.dart`(652), `sidebar.dart`(603), `character_module.dart`(498), `outline_visual_preview.dart`(438), `app_providers.dart`(331)

### [+] 抽象接口必须文档化

`KnowledgeModule` 等核心抽象类的每个方法必须有中文文档注释，说明方法契约、参数含义、返回值结构。

## 避免的写法

### [-] firstWhere + orElse 哨兵模式

```dart
// 避免：用自身作为哨兵值
final parent = nodes.firstWhere((n) => n.id == current.parentId, orElse: () => current);
if (parent == current) break;

// 推荐：使用 indexWhere
final idx = nodes.indexWhere((n) => n.id == current.parentId);
if (idx < 0) break;
current = nodes[idx];
```

### [-] 哑元初始值

```dart
// 避免：构造无效对象仅因非空字段要求
OutlineNode _currentNode = OutlineNode(id: '', title: '', ...);

// 推荐：使用 late 声明
late OutlineNode _currentNode;
```
