import 'package:flutter/material.dart';
import '../outline_node_model.dart';
import '../outline_repository.dart';

class OutlineVisualPreview extends StatefulWidget {
  final OutlineRepository repo;
  final String? bookId;
  final OutlineNode rootNode;

  const OutlineVisualPreview({
    super.key,
    required this.repo,
    this.bookId,
    required this.rootNode,
  });

  @override
  State<OutlineVisualPreview> createState() => _OutlineVisualPreviewState();
}

class _OutlineVisualPreviewState extends State<OutlineVisualPreview> {
  static const _cardWidth = 168.0;
  static const _cardHeight = 104.0;
  static const _hSpacing = 36.0;
  static const _verticalOffset = 72.0;

  List<OutlineNode> _children = [];
  OutlineNode _currentNode;
  final List<String> _breadcrumb = [];
  bool _isLoading = true;

  _OutlineVisualPreviewState() : _currentNode = OutlineNode(id: '', title: '', createdAt: DateTime.now(), updatedAt: DateTime.now());

  @override
  void initState() {
    super.initState();
    _currentNode = widget.rootNode;
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoading = true);
    final children = await widget.repo.getChildren(
      _currentNode.id,
      bookId: widget.bookId,
    );
    if (!mounted) return;
    final node = await widget.repo.getById(_currentNode.id);
    if (!mounted) return;
    setState(() {
      if (node != null) _currentNode = node;
      _children = children;
      _isLoading = false;
    });
  }

  void _navigateToChild(OutlineNode child) {
    setState(() {
      _breadcrumb.add(_currentNode.id);
      _currentNode = child;
    });
    _loadChildren();
  }

  void _goBack() {
    if (_breadcrumb.isNotEmpty) {
      final parentId = _breadcrumb.removeLast();
      setState(() {
        _currentNode = OutlineNode(id: parentId, title: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
      });
      _loadChildren();
    } else if (_currentNode.parentId != null) {
      _goToParent();
    }
  }

  Future<void> _goToParent() async {
    final parentId = _currentNode.parentId;
    if (parentId == null) return;
    final parent = await widget.repo.getById(parentId);
    if (parent == null || !mounted) return;
    setState(() => _currentNode = parent);
    _loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(child: _buildCanvas(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (_breadcrumb.isNotEmpty || _currentNode.parentId != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              tooltip: '返回上一级',
              onPressed: _goBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 4),
          ],
          Icon(Icons.account_tree, size: 16,
              color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _currentNode.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_breadcrumb.isNotEmpty || _currentNode.parentId != null) ...[
            const SizedBox(width: 8),
            Text(
              '${_breadcrumb.length + 1} 级',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
            ),
          ],
          const SizedBox(width: 12),
          Text(
            '${_children.length} 个子节点',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_children.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined, size: 48,
                color: Theme.of(context).colorScheme.outline.withAlpha(80)),
            const SizedBox(height: 12),
            Text(_currentNode.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('此节点下暂无子节点',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline, fontSize: 13)),
          ],
        ),
      );
    }

    const cardWidth = _cardWidth;
    const cardHeight = _cardHeight;
    const hSpacing = _hSpacing;
    const verticalOffset = _verticalOffset;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth =
            _children.length * (cardWidth + hSpacing) + hSpacing * 2;
        final centerY = constraints.maxHeight / 2;
        final canvasWidth = totalWidth > constraints.maxWidth
            ? totalWidth
            : constraints.maxWidth;

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),
          minScale: 0.3,
          maxScale: 2.5,
          child: SizedBox(
            width: canvasWidth,
            height: constraints.maxHeight,
            child: CustomPaint(
              painter: _BranchPainter(
                childCount: _children.length,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                hSpacing: hSpacing,
                verticalOffset: verticalOffset,
                centerY: centerY,
                color: Theme.of(context).colorScheme.outline,
              ),
              child: Stack(
                children: _children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  final isEven = index % 2 == 0;
                  final x = hSpacing + index * (cardWidth + hSpacing);
                  final y = isEven
                      ? centerY - verticalOffset - cardHeight
                      : centerY + verticalOffset;

                  return Positioned(
                    left: x,
                    top: y,
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildNodeCard(context, child, isEven),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNodeCard(BuildContext context, OutlineNode node, bool isAbove) {
    final theme = Theme.of(context);

    final Color statusColor;
    final String statusLabel;
    switch (node.status) {
      case 'planning':
        statusColor = Colors.grey;
        statusLabel = '规划中';
      case 'writing':
        statusColor = Colors.blue;
        statusLabel = '写作中';
      case 'done':
        statusColor = Colors.green;
        statusLabel = '已完成';
      default:
        statusColor = Colors.grey;
        statusLabel = node.status;
    }

    final Color typeColor;
    final String typeLabel;
    final IconData typeIcon;
    switch (node.type) {
      case 'main_arc':
        typeColor = Colors.deepPurple;
        typeLabel = '主线';
        typeIcon = Icons.flag;
      case 'sub_arc':
        typeColor = Colors.indigo;
        typeLabel = '支线';
        typeIcon = Icons.subdirectory_arrow_right;
      case 'scene':
        typeColor = Colors.teal;
        typeLabel = '场景';
        typeIcon = Icons.movie;
      default:
        typeColor = Colors.blueGrey;
        typeLabel = '自由';
        typeIcon = Icons.circle;
    }

    // 连接点小圆
    final connectorDot = Positioned(
      left: _cardWidth / 2 - 5,
      top: isAbove ? _cardHeight - 3 : -7,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: statusColor,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.surface, width: 2),
        ),
      ),
    );

    return GestureDetector(
      onDoubleTap: () => _navigateToChild(node),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surface,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(typeIcon, size: 14, color: typeColor),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                              fontSize: 9, color: typeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (node.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      node.description.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.outline.withAlpha(180),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: statusColor.withAlpha(80), width: 0.5),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(fontSize: 10, color: statusColor),
                        ),
                      ),
                      const Spacer(),
                      if (node.expectedWordCount > 0)
                        Text(
                          '${node.expectedWordCount}字',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            connectorDot,
          ],
        ),
      ),
    );
  }
}

class _BranchPainter extends CustomPainter {
  final int childCount;
  final double cardWidth;
  final double cardHeight;
  final double hSpacing;
  final double verticalOffset;
  final double centerY;
  final Color color;

  _BranchPainter({
    required this.childCount,
    required this.cardWidth,
    required this.cardHeight,
    required this.hSpacing,
    required this.verticalOffset,
    required this.centerY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (childCount == 0) return;

    final linePaint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color.withAlpha(140)
      ..style = PaintingStyle.fill;

    // 中央水平线
    final leftX = hSpacing + cardWidth / 2;
    final rightX =
        hSpacing + (childCount - 1) * (cardWidth + hSpacing) + cardWidth / 2;
    canvas.drawLine(Offset(leftX, centerY), Offset(rightX, centerY), linePaint);

    // 每个子节点的连接线
    for (int i = 0; i < childCount; i++) {
      final isAbove = i % 2 == 0;
      final stemX = hSpacing + i * (cardWidth + hSpacing) + cardWidth / 2;
      final cardEdgeY = isAbove
          ? centerY - verticalOffset - cardHeight
          : centerY + verticalOffset + cardHeight;

      // 中心点圆
      canvas.drawCircle(Offset(stemX, centerY), 3.5, dotPaint);

      // 竖直线段连接
      canvas.drawLine(
        Offset(stemX, centerY),
        Offset(stemX, cardEdgeY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BranchPainter oldDelegate) =>
      childCount != oldDelegate.childCount ||
      cardWidth != oldDelegate.cardWidth ||
      cardHeight != oldDelegate.cardHeight ||
      hSpacing != oldDelegate.hSpacing ||
      verticalOffset != oldDelegate.verticalOffset ||
      centerY != oldDelegate.centerY ||
      color != oldDelegate.color;
}
