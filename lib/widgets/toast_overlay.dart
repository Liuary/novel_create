import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class ToastOverlay extends ConsumerWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(toastProvider);
    if (messages.isEmpty) return const SizedBox.shrink();

    return Positioned(
      right: 24,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final msg in messages)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _ToastText(msg.text),
            ),
        ],
      ),
    );
  }
}

class _ToastText extends StatelessWidget {
  final String text;
  const _ToastText(this.text);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: color,
        shadows: [
          Shadow(
            color: brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: 2,
          ),
          Shadow(
            color: brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
