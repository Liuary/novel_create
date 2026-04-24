# 阶段1 - 基础框架 + 书籍章节编辑

## 状态

已完成

## 目标

搭建项目架构，实现 PC 布局（侧边栏+编辑器），完成书籍、卷、章节的 CRUD、纯文本内容编写、阅读模式标注、导出。

## 步骤

1. 更新 pubspec.yaml 添加依赖（flutter_riverpod, uuid, path_provider, path, flutter_localizations）
2. 创建数据模型（Book, Volume, Chapter, Annotation）
3. 实现 JSON 存储服务
4. 实现状态管理 Providers（Riverpod 3.x, StateProvider 使用 legacy API）
5. 实现 PC 主布局（左侧树形导航 + 右侧编辑区）
6. 实现纯文本写作模式（TextField）
7. 实现阅读模式 + 浮动标记工具栏（自定义 AnnotatedTextController 渲染标注）
8. 实现重命名功能（书籍/卷/章节右键菜单）
9. 实现导出服务（Markdown 纯文本导出）
10. 替换默认 main.dart（Material3 + 中文本地化）

## 技术决策变更

| 原计划 | 变更为 | 原因 |
|--------|--------|------|
| flutter_quill 富文本编辑 | 纯文本 TextField | 网文创作以纯文本为主，不需要复杂富文本工具栏 |
| 富文本工具栏 | 写作/阅读双模式 | 阅读模式支持标注（下划线、删除线、涂色） |
| Quill Delta JSON 存储 | 纯文本 + Annotation 列表 | 简化存储，标注与文本分离 |
