# 阶段2.arch — 模块系统架构优化

## 问题诊断

基于多人协作场景分析，当前模块系统存在以下瓶颈：

### 1. 注册硬编码（高）
`main.dart` 中 `registry.register(OutlineModule())` 是硬编码。N 个开发者同时添加模块时，必然产生合并冲突。

### 2. ModuleContext 可变字段共享（中）
`contextRef.currentBookId` / `currentChapterId` 被模块 widget 直接赋值。同一 `ModuleContext` 实例被所有模块共享，存在跨模块覆盖风险。且模块 widget 混合使用 Riverpod 和命令式两种状态管理范式。

### 3. EventBus 闲置（低）
`AppEvent` 枚举已定义但从未被使用。模块间通信走注册表直接方法调用，与设计意图（事件驱动）不一致。

## 优化方案

### A. 模块注册去硬编码（优先级：高）

**目标**：添加新模块不需要修改 `main.dart`，合并冲突降至最低。

**方案**：创建 `lib/modules/modules.dart` 作为模块聚合文件。

```dart
// lib/modules/modules.dart
import 'outline/outline_module.dart';
// import 'character/character_module.dart';   // 2.3a
// import 'worldbuilding/world_module.dart';  // 2.3b

List<KnowledgeModule> createAllModules() => [
  OutlineModule(),
  // CharacterModule(),
  // WorldModule(),
];
```

**变更影响**：
- `main.dart` 改为 `createAllModules().forEach(registry.register)`
- 新增模块只需在 `modules.dart` 添加 import + 构造函数
- `main.dart` 不再随模块增加而修改

**文件变更**：1 新建 (`modules.dart`) + 1 修改 (`main.dart`)

---

### B. ModuleContext 状态管理规范化（优先级：中）

**目标**：消除模块对 `ModuleContext` 可变字段的直接赋值，统一使用 Riverpod。

**方案**：
1. `ModuleContext.currentBookId` / `currentChapterId` 改为只读 getter，从 Provider 取值
2. 所有模块 widget 直接使用 `ref.watch(currentBookIdProvider)` / `ref.watch(currentChapterIdProvider)`
3. 删除 `_OutlineEditorHostState.initState` 中对 `contextRef.currentBookId` 的赋值

```dart
// ModuleContext — 移除 setter，改为只读
class ModuleContext {
  // ...
  String? get currentBookId => /* 从 Riverpod 读取 */;
  String? get currentChapterId => /* 从 Riverpod 读取 */;
}
```

**变更影响**：
- `module_context.dart`：字段改为 final + getter
- `outline_module.dart`：`_OutlineEditorHostState` 删除赋值逻辑
- 其他文件无影响（已有多处直接使用 Provider）

**文件变更**：2 修改

---

### C. EventBus 启用（优先级：低，可延后至阶段3）

**目标**：将模块间通信从直接方法调用改为事件发布/订阅。

**方案**：
1. `ModuleRegistry.onChapterSaved` → `EventBus.fire(ChapterSavedEvent(...))`
2. 各模块在 `initialize()` 中 `EventBus.on<ChapterSavedEvent>().listen(...)`
3. 保持 `ModuleRegistry.notifyChapterSaved` 作为同步聚合入口

**变更影响**：
- 模块代码从命令式改为响应式
- 现有功能不受影响（`OutlineModule.onChapterCompleted` 改为监听事件）

**文件变更**：3-4 修改

**延后理由**：当前只有一个模块，事件驱动优势不显；阶段3 AI 多路并行时再启用，收益更大。

---

## 执行顺序

| 序号 | 子阶段 | 文件数 | 风险 |
|------|--------|--------|------|
| A | 模块注册去硬编码 | 2 | 低 — 纯重构 |
| B | ModuleContext 规范化 | 2 | 低 — 行为不变 |
| C | EventBus 启用 | 3-4 | 中 — 行为有变化 |

A、B 可在本迭代立即执行。C 延后至阶段3。

## 验收标准

- [ ] `main.dart` 不再包含模块构造函数调用
- [ ] 新增模块只需修改 1 个文件 (`modules.dart`)
- [ ] `ModuleContext` 不再有可变 setter
- [ ] 所有 bookId/chapterId 读写通过 Riverpod Provider
- [ ] `flutter analyze` 零问题
