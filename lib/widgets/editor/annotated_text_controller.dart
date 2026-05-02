import 'package:flutter/material.dart';
import '../../models/annotation.dart';

class TextSegment {
  final String text;
  final bool hasUnderline;
  final Color? underlineColor;
  final bool hasStrikethrough;
  final Color? strikethroughColor;
  final bool hasHighlight;
  final Color? highlightColor;

  const TextSegment({
    required this.text,
    required this.hasUnderline,
    this.underlineColor,
    required this.hasStrikethrough,
    this.strikethroughColor,
    required this.hasHighlight,
    this.highlightColor,
  });

  bool styleEquals(TextSegment other) =>
      hasUnderline == other.hasUnderline &&
      underlineColor == other.underlineColor &&
      hasStrikethrough == other.hasStrikethrough &&
      strikethroughColor == other.strikethroughColor &&
      hasHighlight == other.hasHighlight &&
      highlightColor == other.highlightColor;

  TextSegment mergedWith(TextSegment other) => TextSegment(
        text: text + other.text,
        hasUnderline: hasUnderline,
        underlineColor: underlineColor,
        hasStrikethrough: hasStrikethrough,
        strikethroughColor: strikethroughColor,
        hasHighlight: hasHighlight,
        highlightColor: highlightColor,
      );
}

class AnnotatedTextController extends TextEditingController {
  List<Annotation> annotations = [];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(text: '', style: style);
    }
    final baseStyle = (style ?? const TextStyle(fontSize: 16)).copyWith(
      height: 1.6,
    );
    final segments = _buildSegments(text);

    final merged = <TextSegment>[];
    for (final seg in segments) {
      if (merged.isNotEmpty && merged.last.styleEquals(seg)) {
        merged.last = merged.last.mergedWith(seg);
      } else {
        merged.add(seg);
      }
    }

    return TextSpan(
      style: baseStyle,
      children: merged.map((seg) {
        TextStyle s = baseStyle;
        if (seg.hasUnderline) {
          s = s.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: seg.underlineColor,
          );
        }
        return TextSpan(text: seg.text, style: s);
      }).toList(),
    );
  }

  List<TextSegment> _buildSegments(String text) {
    final breakpoints = <int>{0, text.length};
    for (final a in annotations) {
      if (a.startOffset >= 0 && a.startOffset <= text.length) {
        breakpoints.add(a.startOffset);
      }
      if (a.endOffset >= 0 && a.endOffset <= text.length) {
        breakpoints.add(a.endOffset);
      }
    }
    final sorted = breakpoints.toList()..sort();

    final segments = <TextSegment>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      final start = sorted[i];
      final end = sorted[i + 1];
      if (start >= end) continue;

      final segText = text.substring(start, end);
      String? ulColor;
      String? stColor;
      String? hlColor;

      for (final a in annotations) {
        if (a.startOffset <= start && a.endOffset >= end) {
          switch (a.type) {
            case AnnotationType.underline:
              ulColor = a.colorHex;
            case AnnotationType.strikethrough:
              stColor = a.colorHex;
            case AnnotationType.highlight:
              hlColor = a.colorHex;
          }
        }
      }

      segments.add(
        TextSegment(
          text: segText,
          hasUnderline: ulColor != null,
          underlineColor: ulColor != null
              ? Color(int.parse('FF$ulColor', radix: 16))
              : null,
          hasStrikethrough: stColor != null,
          strikethroughColor: stColor != null
              ? Color(int.parse('FF$stColor', radix: 16))
              : null,
          hasHighlight: hlColor != null,
          highlightColor: hlColor != null
              ? Color(int.parse('FF$hlColor', radix: 16))
              : null,
        ),
      );
    }
    return segments;
  }

  void rebuildText() {
    final oldText = text;
    value = TextEditingValue(text: oldText, selection: selection);
  }
}
