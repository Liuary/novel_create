# 侧边栏重构 & 未保存逻辑

## 需求

侧边栏由三级结构（书籍→卷→章）改为两级结构：
- 选中书籍后，标题栏显示书籍名称，可点击返回作品列表
- 下方只显示卷和章两级

## 未保存弹窗逻辑

### 触发条件

| 操作 | 检测回调 | 说明 |
|------|---------|------|
| 切章节 | `_onChapterChanging` | ref.listen(currentChapterIdProvider) → 章节ID变化 |
| 离开编辑页 | `_onLeavingChapter` | ref.listen(currentChapterIdProvider) → null |
| 切卷 | `_onLeavingChapter` | ref.listen(currentVolumeIdProvider) → null |
| 返回书籍列表 | `_onLeavingChapter` | ref.listen(currentBookIdProvider) → null |

### 弹窗选项

| 选项 | 行为 |
|------|------|
| 保存 | 调用 `_saveCurrentChapter(silent: true)`，清 dirty，设置新 provider 值 |
| 放弃 | 调用 `_clearDirty()`，设置新 provider 值 |
| 取消 | 调用 `_restoreProviderState()` 恢复三个 provider 到加载时状态 |

### 注意点

- `onCancel` 必须恢复所有三个 provider（bookId, volumeId, chapterId），否则用户会被留在不一致的导航状态
- provider 恢复需用 `Future.microtask` 延迟清理 guard（详见 [双弹窗笔记](./double_dialog_guard.md)）

### 重启后章节不加载

`_onChapterChanging` 的 else 分支（无未保存更改时）原先只清 guard 不加载章节。
重启后所有 provider 为 null，用户点章节触发 `ref.listen` → `_onChapterChanging`，由于 `_hasUnsavedChanges = false`，
进入 else 分支但不加载内容。修复：else 分支中调用 `_loadCurrentChapter()`。
