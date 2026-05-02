import 'package:flutter/material.dart';

void showRenameDialog(
    BuildContext context, String title, String initialValue,
    ValueChanged<String> onConfirm) {
  final controller = TextEditingController(text: initialValue);
  doConfirm() {
    final text = controller.text.trim();
    if (text.isNotEmpty) onConfirm(text);
  }
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: '新名称'),
        onSubmitted: (_) => doConfirm(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: doConfirm, child: const Text('确定')),
      ],
    ),
  );
}
