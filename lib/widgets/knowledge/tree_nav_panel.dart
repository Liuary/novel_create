import 'package:flutter/material.dart';

class TreeNavNode {
  final String id;
  final String title;
  final bool hasChildren;
  final String? parentId;
  final int level;
  final Widget? leading;

  const TreeNavNode({
    required this.id,
    required this.title,
    this.hasChildren = false,
    this.parentId,
    this.level = 0,
    this.leading,
  });
}

class TreeNavPanel extends StatefulWidget {
  final List<TreeNavNode> nodes;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final List<PopupMenuItem<String>> Function(String id)? contextMenuBuilder;
  final String Function(String id)? childrenLoader;
  final Set<String>? expandedIds;
  final void Function(String id, bool expanded)? onToggleExpand;

  const TreeNavPanel({
    super.key,
    required this.nodes,
    this.selectedId,
    required this.onSelect,
    this.contextMenuBuilder,
    this.childrenLoader,
    this.expandedIds,
    this.onToggleExpand,
  });

  @override
  State<TreeNavPanel> createState() => _TreeNavPanelState();
}

class _TreeNavPanelState extends State<TreeNavPanel> {
  final Set<String> _localExpandedIds = {};
  Set<String> get _expandedIds => widget.expandedIds ?? _localExpandedIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rootNodes = widget.nodes.where((n) => n.parentId == null).toList();
    return ListView(
      children: rootNodes.map((n) => _buildNode(n, theme)).toList(),
    );
  }

  void _toggleExpand(String id) {
    final isExpanded = _expandedIds.contains(id);
    if (widget.onToggleExpand != null) {
      widget.onToggleExpand!(id, !isExpanded);
      return;
    }
    setState(() {
      if (isExpanded) {
        _localExpandedIds.remove(id);
      } else {
        _localExpandedIds.add(id);
      }
    });
  }

  Widget _buildNode(TreeNavNode node, ThemeData theme) {
    final isSelected = node.id == widget.selectedId;
    final isExpanded = _expandedIds.contains(node.id);
    final children = widget.nodes.where((n) => n.parentId == node.id).toList();
    final contextMenu = widget.contextMenuBuilder?.call(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onSecondaryTapDown: contextMenu != null && contextMenu.isNotEmpty
              ? (details) => _showContextMenu(details, contextMenu)
              : null,
          child: Container(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withAlpha(100)
                : Colors.transparent,
            padding: EdgeInsets.only(
              left: 8.0 + node.level * 16.0,
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                if (node.hasChildren || children.isNotEmpty)
                  GestureDetector(
                    onTap: () => _toggleExpand(node.id),
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 18,
                    ),
                  )
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 4),
                if (node.leading != null) ...[node.leading!, const SizedBox(width: 4)],
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onSelect(node.id),
                    child: Text(
                      node.title,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && children.isNotEmpty)
          ...children.map((c) => _buildNode(c, theme)),
      ],
    );
  }

  void _showContextMenu(
      TapDownDetails details, List<PopupMenuItem<String>> items) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx + 1,
        details.globalPosition.dy + 1,
      ),
      items: items,
    );
  }
}
