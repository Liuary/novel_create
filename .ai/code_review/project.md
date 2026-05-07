# project 阶段 — 代码审查结论（第三轮）

> 审查: 2026-05-07 | 验收: 2026-05-07

## 核心发现

### REV-001（high, fixing）: 数据库同步 fire-and-forget
`app_providers.dart` 6 个同步方法虽已改为 `Future<void>` + `await`，但 9 处调用方仍用 `unawaited()`，try-catch 防护链未闭合。需将 `unawaited()` 替换为 `await`。

### REV-002（high, closed）: getAll(null) 语义统一
`OutlineRepository.getAll(null)` 已不再过滤 `bookId.isNull()`，与 `CharacterRepository` 行为一致。

### REV-007（medium, fixing）: _save 缺 mounted 检查
`outline_node_editor.dart:98` 在 `await widget.repo.update()` 后缺 `if (!mounted) return;`，可能导致 widget 销毁后访问异常。

## 通过的关键修复（14 条）

| REV | 简述 | 修复方式 |
|-----|------|----------|
| 003 | DB 写入 fire-and-forget | 全部加 `await` + `try-catch` |
| 004 | handleLink 缺 linkType 检查 | 加 `if (linkType != 'bound_to') return;` |
| 005 | copyWith 无法传递 null | 引入 `_sentinel` 哨兵值模式 |
| 006 | 书籍切换不刷新 | `ref.listen(currentBookIdProvider, ...)` |
| 008 | annotationColorsHex 重复 | 两处引用常量 |
| 009 | delete 缺事务 | 三个仓储包裹 `_db.transaction()` |
| 010 | 静默吞异常 | `catch(_)` → `catch(e) { debugPrint(...) }` |
| 012 | 接口缺文档 | 全部方法添加中文注释 |
| 013 | EntityLink 无去重 | `getSingleOrNull` 5 元组检查 |
| 014 | 哑元初始值 | `late` 声明替代 |
| 015 | 未使用 ref | `ConsumerWidget` → `StatelessWidget` |
| 016 | orElse 哨兵晦涩 | `firstWhere` → `indexWhere` |
| 017 | 串行初始化 | `for+await` → `Future.wait` |

## 待处理（2 条，low）

- REV-011: 多文件超过 200 行规范阈值
- REV-018: aliases 类型不一致
