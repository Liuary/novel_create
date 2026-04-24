# 最后操作状态 - 2026-04-25 03:26

## 已解决：删除线/涂色高度对齐

**方案**：放弃通过 `TextSpan` 渲染删除线和涂色，改用 `CustomPaint` 覆盖层绘制，手动对齐 Y 坐标。

**实现细节**：
1. `buildTextSpan()` 仅保留下划线（`TextDecoration.underline`），移除 `TextDecoration.lineThrough` 和 `backgroundColor`
2. 新增 `_DecorationPainter`（`CustomPainter`），通过 `RenderEditable.getBoxesForSelection()` 获取标注文本的位置
3. Y 坐标归一化：将 `box.top` 转换回 `TextPainter` 坐标空间（加回 scrollOffset），按 `preferredLineHeight` 对齐到行边界，再转回渲染坐标空间
4. 涂色使用 `CustomPaint.painter`（文字背后），删除线使用 `CustomPaint.foregroundPainter`（文字前方）
5. 通过 `Listenable.merge([scrollController, textController])` 确保滚动和文本变更时重绘

**根因确认**：Flutter `RenderEditable.getBoxesForSelection()` 返回的 `TextBox` 虽然已含 `_paintOffset`，但同一行不同 `TextSpan` 子节点的 ascent 差异导致 `box.top` 不同。`forceStrutHeight` 仅强制行高一致，不影响单个文本运行的度量。

## 阶段1 其他功能

完整功能清单见 `.ai/plan/phase1/index.md`。其他功能均正常。
