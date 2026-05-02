import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_item.dart';

class TreeItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final List<MenuItem> menuItems;
  final int depth;
  final Widget? trailing;
  final Widget? leading;

  const TreeItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.menuItems = const [],
    this.depth = 0,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTapDown: (details) {
        if (menuItems.isNotEmpty) {
          _showContextMenu(context, details.globalPosition);
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 8.0 + depth * 20,
          right: 8,
          top: 4,
          bottom: 4,
        ),
        decoration: depth == 1 && isSelected
            ? BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.zero,
              )
            : null,
        child: Row(
          children: [
            ?leading,
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: menuItems
          .map((item) => PopupMenuItem(
                value: item,
                child: Row(
                  children: [
                    Icon(item.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(item.label),
                  ],
                ),
              ))
          .toList(),
    ).then((value) {
      if (value is MenuItem) value.onTap();
    });
  }
}
