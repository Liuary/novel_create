总进度：阶段2 大纲模块（2.2）完成 + 架构优化（2.arch-A/B）完成

@Liuary 大纲模块端到端功能完整。多人协作瓶颈已解决：模块注册通过 modules.dart 聚合去硬编码（main.dart 不再需要逐个 import），ModuleContext 可变字段已移除、统一走 Riverpod。下一步可启动角色模块 2.3a 或背景模块 2.3b。
