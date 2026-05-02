# 子阶段 2.5 — 打磨与三期预制

## 状态

🔜 待开始

## 定位

在所有知识库模块完成后，统一打磨全局体验，完成三期所需的基础设施。

---

## 1. 任务清单

### 1.1 全局搜索优化

- 完善 `ModuleRegistry.searchAll()` — 集成所有模块的搜索结果
- 搜索结果统一展示 UI（左侧搜索栏已有框架，需对接模块搜索）
- 搜索结果可点击跳转到对应模块详情
- 搜索性能优化（SQLite LIKE → 可选项：FTS5 全文索引）

### 1.2 知识库 Tab 完善

- 左侧 Tab "内容树 / 知识库" 完善 UI
- "知识库"Tab 下显示已注册模块列表（点击切换对应模块的导航面板）
- 当前选中章节时，知识库面板显示绑定实体摘要

### 1.3 上下文装配器最终化

`ModuleRegistry.assembleContext()` 已实现基础逻辑，需完善：
- 增加 `chapterId` 有效性校验
- 输出格式标准化（统一 `moduleId` 作为 key）
- 添加模块自身的 `displayName` 到输出中

### 1.4 右侧属性面板完善

- 属性面板入口：侧边栏/编辑器中的按钮打开右侧面板
- 面板根据当前选中实体（章节/角色/大纲节点等）动态加载对应模块的 `buildInspector()`
- 面板宽度可拖拽调整
- 面板显示/隐藏动画

### 1.5 StyleProfiles CRUD UI

风格配置表 `style_profiles` 已建表，需实现 UI：
- 列表页面（名称 + 预览）
- 编辑页面（系统提示词、示例文本、参数 JSON 编辑器）
- 为三期 AI 写作提供配置入口

### 1.6 TextAnalyzer（检测工具框架）

```dart
class TextAnalyzer {
  // 统计
  Map<String, int> getWordFrequency(String text);     // 高频词
  List<double> getSentenceLengths(String text);       // 句长分布
  int getAverageSentenceLength(String text);          // 平均句长
  int getParagraphCount(String text);                 // 段落数
  Map<String, double> getTextStats(String text);      // 综合报告

  // 输出 JSON 报告
  Map<String, dynamic> analyze(String text);
}
```

### 1.7 检测报告 UI

- 基于 TextAnalyzer 输出渲染可视化报告
- 高频词云图（可选，使用简单的文字标签替代）
- 句长分布柱状图
- 基本统计数字面板

---

## 2. 文件结构

```
lib/
├── services/
│   └── text_analyzer.dart            # 新建
├── widgets/
│   ├── knowledge/
│   │   ├── search_results_panel.dart # 新建（全局搜索结果面板）
│   │   └── stats_report.dart         # 新建（检测报告 UI）
│   └── style_profile_editor.dart     # 新建
├── modules/ (各模块已有)
└── providers/app_providers.dart      # 更新（文字分析 provider）
```

---

## 3. 验证点

- [ ] 全局搜索覆盖所有模块，结果可跳转
- [ ] 知识库 Tab 可切换各模块导航
- [ ] StyleProfiles CRUD 可用
- [ ] TextAnalyzer 统计结果正确
- [ ] 检测报告 UI 渲染正常
- [ ] `flutter analyze` 零问题
