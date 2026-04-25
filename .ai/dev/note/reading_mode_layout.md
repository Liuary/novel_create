# 阅读模式布局 BUG

## 问题1：每行只显示一个字 + 滚动条出现在编辑器中央

### 根因

`_buildReadingMode` 中结构为：

```
Scrollbar(controller: _readScrollController)
  Theme
    Stack
      Positioned.fill
        CustomPaint(painter, foregroundPainter, child: TextField)
      if (showToolbar) Positioned(...)
```

`Scrollbar` 包裹了 `Stack`，依据 `_readScrollController` 计算滚动条位置。
但 `Stack` 内部 `TextField` 通过 `Positioned.fill` 扩展，其滚动视图的范围与 `Scrollbar` 预期的 viewport 不匹配，
导致滚动条定位到错误位置。

同时 `TextField` 使用了 `StrutStyle(height: 1.6, forceStrutHeight: true)`，在阅读模式下此配置不必要，
且可能与 `expands: true` 的组合产生异常换行行为。

### 修复

1. **移动 Scrollbar 到 Stack 内部**，直接包裹 TextField，消除滚动条定位偏差
2. **移除 Positioned.fill**（随之变为不需要），CustomPaint 直接作为 Stack child，通过自身约束传递
3. **移除阅读模式 TextField 的 StrutStyle(forceStrutHeight: true)**— 该配置仅为写作模式光标稳定所需

修正后结构：

```
GestureDetector
  Container
    Stack
      CustomPaint(painter, foregroundPainter,
        child: Scrollbar
          Theme
            TextField(expands: true, no StrutStyle)
      if (showToolbar) Positioned(...)
      _buildAutoSaveNotification()
```

## 问题2：阅读模式每行只显示一个字（疑似 StrutStyle 导致）

独立于上述 Stack/Scrollbar 问题的另一种表现。`forceStrutHeight: true` 强制每行高度严格等于
`fontSize * height`，在 `expands: true` 的 TextField 中可能导致字符宽度分配异常。
移除阅读模式的 StrutStyle 后修复。
