# 全局消息提示系统

## 需求

- 右下角浮动消息队列，纯文字+异色描边（无背景框）
- 每条显示3秒后消失，最多同时显示5条
- 新消息出现在底部，将旧消息向上顶
- 消息过期后逐个消失，队列中等待的消息继续显示
- 独立于编辑页面，各模块均可调用
- 自动保存倒计时在左下角（编辑页内），与右下角消息分离

## 实现

### 新增文件

- `lib/services/toast_service.dart` — `ToastMessage` 模型 + `ToastNotifier(Notifier<List<ToastMessage>>)`
  - `show(text)` 入口
  - `_flush()` 从队列灌到 state（最多5条）
  - `_startDismissTimer()` 3秒后移除最早一条，递归调用 `_flush`
- `lib/widgets/toast_overlay.dart` — `ToastOverlay(ConsumerWidget)`
  - `Positioned(right: 24, bottom: 24)`
  - `Text` widget 带双层 `Shadow` 描边，自适应亮/暗主题

### 修改文件

- `lib/providers/app_providers.dart` — 新增 `toastProvider`（`NotifierProvider`）
  - 注意：Riverpod 3.x 移除 `StateNotifier`，改用 `Notifier`
  - `StateProvider` 移入 `legacy.dart` 子包，需 `show StateProvider`
- `lib/pages/home_page.dart` — `Row` 包裹进 `Stack`，叠加 `ToastOverlay`
- `lib/widgets/editor_page.dart`
  - 替换 `ScaffoldMessenger.showSnackBar` → `ref.read(toastProvider.notifier).show(...)`
  - 替换自动保存完成提示 → `ref.read(toastProvider.notifier).show('自动保存成功')`
  - 自动保存倒计时保留在 `_buildAutoSaveNotification`（`Positioned(left: 24, bottom: 24)`，纯文字+描边）

### 调用方式

```dart
ref.read(toastProvider.notifier).show('消息内容');
```
