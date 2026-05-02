# 开发笔记

## 索引

- [全局消息提示系统](./global_toast_system.md) — 右下角消息队列，纯文字描边，3秒自动消失，最多5条
- [双弹窗 & SwitchProvider Guard 机制](./double_dialog_guard.md) — ref.listen 回调竞争条件和 Future.microtask 延迟清理
- [ref.listen unmount 保护](./ref_listen_unmount.md) — widget 卸载后 ref.listen 回调仍触发的问题
- [阅读模式布局 BUG](./reading_mode_layout.md) — Positioned.fill + CustomPaint + Stack 导致的滚动条错位
- [侧边栏重构 & 未保存逻辑](./sidebar_restructure.md) — 三级变两级，弹窗取消恢复 provider
- [模块系统架构分析](./architecture_analysis.md) — 多人协作瓶颈识别(注册硬编码/ModuleContext可变字段/EventBus闲置)，编辑器-知识库耦合评估，优化方案
