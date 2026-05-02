# 模块系统架构分析

> 来源：2026-05-02 架构审查，已从个人笔记归入公共域

## 多人协作瓶颈

### 1. 模块注册硬编码（高）
`main.dart` 中 `registry.register(OutlineModule())` 硬编码。N 个开发者同时添加模块 → 必然合并冲突。

### 2. ModuleContext 可变字段共享（中）
`contextRef.currentBookId` / `currentChapterId` 被模块 widget 直接赋值，同一实例跨模块共享 → 覆盖风险。模块 widget 混合 Riverpod + 命令式状态管理。

### 3. EventBus 闲置（低）
`AppEvent` 枚举已定义但从未使用。模块间通信走注册表直接方法调用。

## 编辑器 vs 知识库耦合
- 低耦合：二者交替显示（不同时存在），`HomePage` 根据 `activeKnowledgeModuleIdProvider` 编排
- 共享：`ModuleContext`（DB/EventBus/LinkRepo/读写回调）、Riverpod Providers
- 无 Widget 树交叉引用

## 解决方案
详见 [phase2_arch.md](../../plan/phase2/phase2_arch.md) — 已于 2026-05-02 全部实施完成

## 接口完备性
- `KnowledgeModule` 接口设计良好（2 getter + 10 方法），新模块只需实现接口
- `ModuleRegistry` 简洁有效
- `TreeNavPanel` / `TreeUtils` 共享组件可复用
- 注册机制已通过 `modules.dart` 聚合文件去硬编码
- `ModuleContext` 已移除可变字段，统一走 Riverpod
