import 'dart:ui' show AppExitResponse;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/sidebar.dart';
import '../widgets/editor_page.dart';
import '../widgets/toast_overlay.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: _onExitRequested,
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  Future<AppExitResponse> _onExitRequested() async {
    final hasUnsaved = ref.read(hasUnsavedChangesProvider);
    if (!hasUnsaved) return AppExitResponse.exit;

    final action = await showDialog<_ExitDialogAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('未保存的更改'),
        content: const Text('你有未保存的编辑内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_ExitDialogAction.cancel),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_ExitDialogAction.discard),
            child: const Text('放弃'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_ExitDialogAction.save),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    switch (action) {
      case _ExitDialogAction.save:
        final saveFn = ref.read(onExitSaveProvider);
        if (saveFn != null) {
          await saveFn();
        }
        return AppExitResponse.exit;
      case _ExitDialogAction.discard:
        return AppExitResponse.exit;
      case _ExitDialogAction.cancel:
        return AppExitResponse.cancel;
      default:
        return AppExitResponse.exit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              const Sidebar(),
              Expanded(child: EditorPage()),
            ],
          ),
          const ToastOverlay(),
        ],
      ),
    );
  }
}

enum _ExitDialogAction { save, discard, cancel }
