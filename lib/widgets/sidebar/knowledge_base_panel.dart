import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class KnowledgeBasePanel extends ConsumerStatefulWidget {
  final String? currentBookId;
  const KnowledgeBasePanel({super.key, required this.currentBookId});

  @override
  ConsumerState<KnowledgeBasePanel> createState() =>
      _KnowledgeBasePanelState();
}

class _KnowledgeBasePanelState extends ConsumerState<KnowledgeBasePanel> {
  String? _activeModuleId;

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(moduleRegistryProvider);
    final modules = registry.modules;

    if (_activeModuleId != null) {
      final module = registry.getById(_activeModuleId!);
      if (module != null) {
        final nav = module.buildNavigationPanel(context);
        if (nav != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeModuleId = null);
                        ref.read(activeKnowledgeModuleIdProvider.notifier).state = null;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 16,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('返回',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(module.displayName,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: nav),
            ],
          );
        }
      }
    }

    if (modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books_outlined, size: 40,
                color: Theme.of(context).colorScheme.outline.withAlpha(80)),
            const SizedBox(height: 8),
            Text('暂无知识库模块',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12)),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text('知识库模块',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary)),
        ),
        const Divider(height: 1),
        ...modules.map((m) => ListTile(
              dense: true,
              leading: Icon(_moduleIcon(m.moduleId), size: 20),
              title: Text(m.displayName, style: const TextStyle(fontSize: 13)),
              onTap: () {
                setState(() => _activeModuleId = m.moduleId);
                ref.read(activeKnowledgeModuleIdProvider.notifier).state = m.moduleId;
              },
            )),
        Divider(height: 1, color: theme.dividerColor),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.currentBookId != null
                ? '当前书籍的私有知识库'
                : '请先选择书籍以使用私有知识库',
            style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.outline.withAlpha(128)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  IconData _moduleIcon(String moduleId) {
    switch (moduleId) {
      case 'outline':
        return Icons.account_tree_outlined;
      case 'character':
        return Icons.person_outline;
      case 'world':
        return Icons.public_outlined;
      case 'inspiration':
        return Icons.lightbulb_outline;
      case 'item':
        return Icons.category_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }
}
