# 阶段1 - 基础框架 + 书籍章节编辑

## 状态

已完成

## 目标

搭建项目架构，实现 PC 布局（侧边栏+编辑器），完成书籍、卷、章节的 CRUD、纯文本内容编写、阅读模式标注、导出。

## 步骤

1. 更新 pubspec.yaml 添加依赖（flutter_riverpod, uuid, path_provider, path, flutter_localizations）
2. 创建数据模型（Book, Volume, Chapter, Annotation）
3. 实现 JSON 存储服务（用户文档目录）
4. 实现状态管理 Providers（Riverpod 3.x, StateProvider 使用 legacy API）
5. 实现 PC 主布局（左侧树形导航 + 右侧编辑区）
6. 实现纯文本写作模式（TextField）
7. 实现阅读模式 + 浮动标记工具栏
8. 实现重命名功能（书籍/卷/章节右键菜单）
9. 实现导出服务（Markdown 纯文本导出）
10. 替换默认 main.dart（Material3 + 中文本地化）

## 功能清单

### 书籍管理
- ✓ 新建书籍（侧边栏 + 按钮）
- ✓ 删除书籍（右键菜单，含确认对话框）
- ✓ 重命名书籍（右键菜单）
- ✓ 书籍列表持久化（JSON 文件存储）

### 卷管理
- ✓ 新建卷（书籍右键菜单）
- ✓ 删除卷（卷右键菜单，递归删除章节）
- ✓ 重命名卷（卷右键菜单）
- ✓ 卷列表按书籍展开/收起

### 章节管理
- ✓ 新建章节（卷右键菜单）
- ✓ 删除章节（章节右键菜单，删除已打开章节时编辑区自动清空）
- ✓ 重命名章节（章节右键菜单，标题栏内联编辑）

### 写作模式
- ✓ 纯文本 TextField 编辑器
- ✓ 字数统计（排除空白字符，实时更新）
- ✓ 保存按钮（持久化到 JSON 文件）
- ✓ 写作/阅读模式切换

### 阅读模式
- ✓ 只读文本渲染
- ✓ 标注渲染：下划线（`TextDecoration.underline`）、删除线（`TextDecoration.lineThrough`）、涂色（`backgroundColor`）
- ✓ 标注数据模型（Annotation: type + colorHex + offset range）
- ✓ 标注持久化（随章节 JSON 保存/加载）
- ✓ `_AnnotatedTextController` 自定义渲染：按断点拆分文本，逐段叠加样式
- ✓ 删除线回归 `buildTextSpan` 主通道渲染（与下划线共用 `decorationColor`，Flutter 硬限制）
- ✓ 涂色使用 `backgroundColor` 独立通道，不与下划线/删除线冲突

### 浮动标记工具栏
- ✓ 随选区自动出现/消失（`_onReadSelectionChanged` 监听）
- ✓ 根据选区计算位置（`_recalcToolbarPosition`：上半屏在选区下方，下半屏在选区上方）
- ✓ 工具栏保持在输入区域内（`Clip.hardEdge` + X 轴 clamp）
- ✓ 点击工具栏不取消选区（`GestureDetector(onTap: _requestFocus)` + `Focus(canRequestFocus: false)`）
- ✓ 上层 3 按钮：下划线、删除线、涂色（`spaceEvenly` 分布，选中高亮）
- ✓ 下层 8 按钮：清除 + 红橙黄绿蓝靛紫
- ✓ 类型锁定：手动点击类型按钮后，选区变化不再覆盖类型（`_typeLocked` 标记）
- ✓ 智能颜色选择：无标注默认"下划线+清除"；有标注自动选选区最多类型+该类型最多颜色；平局按优先级
- ✓ 标注应用：`expand` 拆分相交标注 + 添加新标注（`_applyColor`）
- ✓ 标注清除：`expand` 拆分移除选区段（`_clearActiveAnnotation`）

### 侧边栏 UI
- ✓ 仅选中章节（depth=2）显示直角底板（`BorderRadius.zero`），横向填满
- ✓ 选中状态传递：选中章节时，其卷和书籍自动加粗（`FontWeight.w600`）
- ✓ 书籍/卷无底板，仅加粗表示选中
- ✓ 右键菜单：重命名、新建子项、删除
- ✓ 新建/删除章节后即时刷新列表（`ref.invalidateSelf()`）

### 编辑器 UI
- ✓ 章节标题点击内联编辑（`_isEditingTitle` 切换 TextField）
- ✓ 写作/阅读切换按钮带图标（`_ModeButton`），选中高亮+加粗，未选灰色
- ✓ 保存按钮无边框（`IconButton`）
- ✓ 移除标题栏 `Divider`，区域过渡柔和
- ✓ 侧边栏与编辑区无缝衔接（无 `VerticalDivider`）
- ✓ 外挂 `Scrollbar(thumbVisibility: true)`，TextField 内部滚动条隐藏（`Theme` 覆写 thickness: 0）

### 版本管理
- ✓ Git 仓库初始化及提交

## 技术决策变更

| 原计划 | 变更为 | 原因 |
|--------|--------|------|
| flutter_quill 富文本编辑 | 纯文本 TextField | 网文创作以纯文本为主，不需要复杂富文本工具栏 |
| 富文本工具栏 | 写作/阅读双模式 | 阅读模式支持标注（下划线、删除线、涂色） |
| Quill Delta JSON 存储 | 纯文本 + Annotation 列表 | 简化存储，标注与文本分离 |

## 已知限制

- Flutter `TextStyle.decorationColor` 只支持单一颜色。同一段文字的下划线和删除线共享颜色（以最后应用的标注颜色为准）。涂色使用 `backgroundColor` 独立通道不受影响。
