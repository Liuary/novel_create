import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToastMessage {
  final String text;
  final DateTime createdAt;

  ToastMessage({
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ToastNotifier extends Notifier<List<ToastMessage>> {
  final List<ToastMessage> _queue = [];
  Timer? _dismissTimer;

  static const int maxVisible = 5;
  static const Duration displayDuration = Duration(seconds: 3);

  @override
  List<ToastMessage> build() {
    ref.onDispose(() => _dismissTimer?.cancel());
    return [];
  }

  void show(String text) {
    _queue.add(ToastMessage(text: text));
    _flush();
  }

  void _flush() {
    while (state.length < maxVisible && _queue.isNotEmpty) {
      state = [...state, _queue.removeAt(0)];
    }
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    if (state.isEmpty) return;
    _dismissTimer = Timer(displayDuration, () {
      if (state.isNotEmpty) {
        state = state.sublist(1);
        _flush();
      }
    });
  }

  void disposeTimer() {
    _dismissTimer?.cancel();
  }
}
