# ref.listen unmount 保护

## 问题

widget 已 unmount 后，`ref.listen` 的回调因 provider 值变化仍被触发。
回调用 `ref.read(...)` 访问 provider 时，BuildContext 已废弃，抛出异常：

```
Bad state: Using "ref" when a widget is about to or has been unmounted is unsafe.
```

堆栈路径：
1. 侧边栏点击 → `currentChapterIdProvider` 变
2. `ref.listen` 回调触发 `_onChapterChanging`
3. `_loadCurrentChapter` 中 `ref.read(currentBookIdProvider)`
4. 此时 widget 已 unmount

## 修复

### 1. ref.listen 回调入口加 mounted 检查

```dart
ref.listen(currentChapterIdProvider, (prev, next) {
  if (!mounted) return;
  // ...
});
```

三个 listen（chapterId/volumeId/bookId）都需要加。

### 2. 回调内的异步操作也要保护

```dart
void _onChapterChanging(String newChapterId) {
  // ...
  onSave: () async {
    await _saveCurrentChapter(silent: true);
    if (!mounted) return;  // 异步回来后检查
    // ...
  },
  onDiscard: () {
    if (!mounted) return;
    // ...
  },
}
```

### 3. _loadCurrentChapter 开头保护

```dart
Future<void> _loadCurrentChapter() async {
  if (!mounted) return;
  // ...
}
```

### 4. dispose 中不要用 ref

```dart
// bad:
@override
void dispose() {
  ref.read(onExitSaveProvider.notifier).state = null;  // ❌
  super.dispose();
}

// good:
@override
void deactivate() {
  ref.read(onExitSaveProvider.notifier).state = null;  // ✅
  super.deactivate();
}
```

`deactivate()` 在 dispose 之前调用，此时 BuildContext 仍有效。
