# 最后操作状态 - 2026-04-25 03:23

## 未解决问题

### 删除线/涂色高度对齐

**现象**：阅读模式下，不同行（或同一行不同文本段）的删除线 Y 位置不一致，涂色背景块高度也不一致。

**已尝试方案**（均未解决）：
1. `TextStyle(height: 1.6)` — 用户反馈"字形诡异"
2. `StrutStyle(forceStrutHeight: true)` — 无效
3. `StrutStyle(forceStrutHeight: true, height: 1.6)` — 无效
4. `TextStyle.height` + `StrutStyle` 同时设置 — 无效
5. `buildTextSpan` 相邻同样式片段合并，减少文本运行数 — 无效

**猜测根因**：Flutter `EditableText` 内部 `TextPainter` 对不同 `TextSpan` 子节点的字体度量独立计算，导致中英文混排时段落内各文本段的 ascent/descent 存在微小差异，`TextDecoration` 和 `backgroundColor` 的渲染位置依赖这些度量而产生偏移。

**建议方向**：可能需要放弃 `TextField` + `buildTextSpan` 方案，改用独立的 `RichText` + `SelectionArea` 或者自定义 `RenderBox` 渲染标注。

## 阶段1 其他功能

完整功能清单见 `.ai/plan/phase1/index.md`。其他功能均正常。
