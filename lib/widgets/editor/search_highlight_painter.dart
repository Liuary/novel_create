import 'package:flutter/material.dart';
import '../search_util.dart';
import '../../utils/render_utils.dart';

class SearchHighlightPainter extends CustomPainter {
  final List<SearchMatch> matches;
  final int currentIndex;
  final GlobalKey areaKey;
  final ScrollController scrollController;
  final TextEditingController textController;

  SearchHighlightPainter({
    required this.matches,
    required this.currentIndex,
    required this.areaKey,
    required this.scrollController,
    required this.textController,
  }) : super(repaint: Listenable.merge([scrollController, textController]));

  @override
  void paint(Canvas canvas, Size size) {
    if (matches.isEmpty) return;

    final areaBox = areaKey.currentContext?.findRenderObject() as RenderBox?;
    if (areaBox == null || !areaBox.attached) return;

    final re = findRenderEditable(areaBox);
    if (re == null || !re.attached) return;

    final reGlobal = re.localToGlobal(Offset.zero);
    final areaGlobal = areaBox.localToGlobal(Offset.zero);
    final reOffset = reGlobal - areaGlobal;

    final lineHeight = re.preferredLineHeight;
    final scrollOffset = scrollController.hasClients
        ? scrollController.offset
        : 0.0;

    final hlPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3);

    final currentPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.5);

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final isCurrent = i == currentIndex;
      final paint = isCurrent ? currentPaint : hlPaint;

      final selection = TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      );

      final boxes = re.getBoxesForSelection(selection);
      for (final box in boxes) {
        final textPainterTop = box.top + scrollOffset;
        final lineIndex = (textPainterTop / lineHeight).round();
        final normalizedTop = lineIndex * lineHeight - scrollOffset;
        final normalizedBottom = normalizedTop + lineHeight;

        canvas.drawRect(
          Rect.fromLTRB(
            box.left + reOffset.dx,
            normalizedTop + reOffset.dy,
            box.right + reOffset.dx,
            normalizedBottom + reOffset.dy,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SearchHighlightPainter oldDelegate) {
    return matches != oldDelegate.matches ||
        currentIndex != oldDelegate.currentIndex;
  }
}
