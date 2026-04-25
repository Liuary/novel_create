# 双弹窗 & SwitchProvider Guard 机制

## 问题

章节切换时，`_onChapterChanging` 的 cancel 回调调用 `_restoreProviderState()` 恢复 provider，
而 `ref.listen(currentChapterIdProvider)` 在 provider 值恢复后会再次触发 `_onChapterChanging`，
导致第二个未保存弹窗。

## 根因

```dart
void _restoreProviderState() {
  _onChapterChangingGuard = true;          // 设置 guard
  ref.read(currentChapterIdProvider.notifier).state = _loadedChapterId;  // 触发 ref.listen
  _onChapterChangingGuard = false;         // 同步清掉 guard
}
```

`ref.listen` 的回调在同步代码**执行完毕后才异步触发**。`_onChapterChangingGuard` 在函数末尾被同步清掉，
而 `ref.listen` 此时还未触发，所以 guard 无效。

## 修复

```dart
void _restoreProviderState() {
  _isChangingChapter = true;
  _onChapterChangingGuard = true;
  ref.read(currentBookIdProvider.notifier).state = _loadedBookId;
  ref.read(currentVolumeIdProvider.notifier).state = _loadedVolumeId;
  ref.read(currentChapterIdProvider.notifier).state = _loadedChapterId;
  Future.microtask(() {
    _isChangingChapter = false;
    _onChapterChangingGuard = false;
  });
}
```

`Future.microtask` 将 guard 清理推迟到当前 microtask 之后，
确保 `ref.listen` 的回调在 guard 为 true 期间同步执行完毕，从而被拦截。

## 相关模式

| 模式 | 用途 | 关键方法 |
|------|------|---------|
| 章节切换未保存 | `_onChapterChanging` | 切换章节前检测，保存/放弃/取消 |
| 离开章节未保存 | `_onLeavingChapter` | provider 设为 null 时检测（返回书籍列表/切换卷） |
| 恢复状态 | `_restoreProviderState` | 取消时恢复三个 provider 到加载时的值 |
