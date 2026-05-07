# 常见问题与排查指南

> 最后更新：2026-05-07

## Dart / Flutter

### [+] `unawaited()` 导致 try-catch 无法捕获异常

**症状**：`debugPrint('DB sync error: $e')` 从不下打印，但 DB 操作实际已失败。

**根因**：方法声明为 `void` 且内部 Future 未被 await，或调用方使用 `unawaited()` 包裹。异步异常抛出到微任务队列，不会被同步 `catch (e)` 块捕获。

**修复**：
1. 方法签名改为 `Future<void>` 并使用 `async/await`
2. 调用方使用 `await` 而非 `unawaited()`

**影响文件**：`lib/providers/app_providers.dart`（`_syncBookToDb`、`_syncVolumeToDb`、`_syncChapterToDb` 等 6 方法）

### [+] `await` 后访问 Widget 前必须检查 `mounted`

**症状**：用户在异步操作期间导航离开页面，`setState` 抛出异常。

**模式**：
```dart
Future<void> _onSave() async {
  await repo.update(data);
  // ❌ 缺少 mounted 检查
  widget.onChanged(data);
  
  // ✅ 正确
  if (!mounted) return;
  widget.onChanged(data);
}
```

**高发位置**：所有 `ConsumerStatefulWidget` / `StatefulWidget` 中涉及 `widget.xxx` 回调的异步方法。

### [+] `copyWith` 无法将可空字段设为 null

**症状**：调用 `node.copyWith(parentId: null)` 后 `parentId` 仍为原值。

**根因**：`copyWith` 对可空参数使用 `??` 运算符（`parentId ?? this.parentId`），无法区分"未传入"和"传入 null"。

**修复**：使用哨兵值模式（见 `.ai/kb/patterns.md`）。

### [+] Drift `getSingle()` 在无结果时抛异常而非返回 null

**症状**：`Repository.create()` 在 `insert` 后用 `getSingle()` 回读，偶尔崩溃。

**根因**：`getSingle()` 在无结果或结果多于 1 条时抛出 `StateError`，不是返回 null。

**修复**：使用 `getSingleOrNull()` 替代 `getSingle()`，或在 try-catch 中处理。

### [+] LIKE 查询特殊字符未转义

**症状**：搜索含 `%` 或 `_` 的用户输入时结果异常多。

**根因**：Drift 的 `.like()` 已做 SQL 参数化（防注入），但 `%` 和 `_` 仍是 LIKE 通配符。

**修复**：对用户输入中的 `%` `_` `\` 做转义：
```dart
final escaped = query
  .replaceAll(r'\', r'\\')
  .replaceAll('%', r'\%')
  .replaceAll('_', r'\_');
```

## 数据库 (Drift/SQLite)

### [+] `getAll(bookId: null)` 语义不一致

**症状**：大纲模块的上下文数据在某些场景下缺失。

**根因**：`OutlineRepository.getAll(null)` 过滤 `bookId.isNull()`（仅返回孤立节点），而 `CharacterRepository.getAll(null)` 返回全部数据。

**修复**：`bookId` 为 null 时不加 where 条件，返回全部数据。仅当显式传入 bookId 时才过滤。

### [+] 事务缺失导致数据不一致

**症状**：删除操作中途失败，部分关联数据残留。

**检查点**：搜索 `_db.delete(` 和 `_db.update(` 调用，确认是否在 `_db.transaction()` 内。

**修复**：包裹在 `await _db.transaction(() async { ... })` 中。

## 状态管理 (Riverpod)

### [+] ConsumerStatefulWidget 不响应 Provider 变化

**症状**：切换书籍后，组件仍显示旧书籍的数据。

**根因**：在 `initState()` 中用 `ref.read()` 读取 provider 快照，但未监听变化。

**修复**：在 `build()` 中用 `ref.listen(provider, (prev, next) { _load(); })` 监听变化。

### [+] 文件拆分时私有方法被跨文件引用

**症状**：拆分文件后编译报错 `The method '_xxx' isn't defined`。

**根因**：同一文件跨类调用私有方法（`_` 前缀），拆到不同文件后不可见。

**修复**：将跨文件使用的方法改为公开（去掉 `_` 前缀），或提取为公共工具函数。
