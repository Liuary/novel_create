# 最后操作状态 - 2026-04-25 03:00

## 阶段1 已完成并归档

完整功能清单见 `.ai/plan/phase1/index.md`。

## 核心修复（本次会话）

- 类型锁定：手动点类型按钮后选区不再覆盖 `_activeType`
- `removeWhere` 移除：`_applyColor` 中 `expand` 已正确处理拆分，不需要前置删除
- 删除线回归 `buildTextSpan`：遮盖层方案因 `RichText` 与 `EditableText` 布局差异导致位置偏移，回归统一渲染通道
- annotation 模型支持独立 type+colorHex

## 已知限制

Flutter `decorationColor` 单一颜色限制，下划线与删除线同时存在时共享颜色。
