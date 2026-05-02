import 'package:flutter/material.dart';
import '../../models/annotation.dart';
import '../../utils/render_utils.dart';

class DecorationPainter extends CustomPainter {
  final List<Annotation> annotations;
  final GlobalKey areaKey;
  final ScrollController scrollController;
  final TextEditingController textController;
  final bool drawHighlights;
  final bool drawStrikethroughs;

  DecorationPainter({
    required this.annotations,
    required this.areaKey,
    required this.scrollController,
    required this.textController,
    required this.drawHighlights,
    required this.drawStrikethroughs,
  }) : super(repaint: Listenable.merge([scrollController, textController]));

  @override
  void paint(Canvas canvas, Size size) {
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

    for (final annotation in annotations) {
      final isHighlight = annotation.type == AnnotationType.highlight;
      final isStrikethrough = annotation.type == AnnotationType.strikethrough;

      if (isHighlight && !drawHighlights) continue;
      if (isStrikethrough && !drawStrikethroughs) continue;
      if (!isHighlight && !isStrikethrough) continue;

      final selection = TextSelection(
        baseOffset: annotation.startOffset,
        extentOffset: annotation.endOffset,
      );

      final boxes = re.getBoxesForSelection(selection);
      if (boxes.isEmpty) continue;

      final color = Color(
        int.parse('FF${annotation.colorHex ?? annotationColorsHex[2]}', radix: 16),
      );

      for (final box in boxes) {
        final textPainterTop = box.top + scrollOffset;
        final lineIndex = (textPainterTop / lineHeight).round();
        final normalizedTop = lineIndex * lineHeight - scrollOffset;
        final normalizedBottom = normalizedTop + lineHeight;

        final left = box.left + reOffset.dx;
        final right = box.right + reOffset.dx;
        final top = normalizedTop + reOffset.dy;
        final bottom = normalizedBottom + reOffset.dy;

        if (isHighlight) {
          final paint = Paint()..color = color.withValues(alpha: 0.3);
          canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
        } else if (isStrikethrough) {
          final paint = Paint()
            ..color = color
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round;
          final y = top + (bottom - top) * 0.55;
          canvas.drawLine(Offset(left, y), Offset(right, y), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant DecorationPainter oldDelegate) {
    return annotations != oldDelegate.annotations ||
        drawHighlights != oldDelegate.drawHighlights ||
        drawStrikethroughs != oldDelegate.drawStrikethroughs;
  }
}
