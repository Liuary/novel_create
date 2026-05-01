import 'package:flutter/material.dart';

class ChapterSearchResult {
  final String bookId;
  final String volumeId;
  final String volumeName;
  final String chapterId;
  final String chapterName;
  final String content;
  final int matchPosition;
  final int proximityIndex;
  final bool isTitleMatch;

  const ChapterSearchResult({
    required this.bookId,
    required this.volumeId,
    required this.volumeName,
    required this.chapterId,
    required this.chapterName,
    required this.content,
    required this.matchPosition,
    required this.proximityIndex,
    this.isTitleMatch = false,
  });
}

class SearchMatch {
  final int start;
  final int end;
  const SearchMatch(this.start, this.end);
}

/// 在文本中查找所有匹配（不区分大小写）
List<SearchMatch> findAllMatches(String text, String query) {
  if (query.isEmpty || text.isEmpty) return [];
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final matches = <SearchMatch>[];
  int start = 0;
  while (true) {
    final idx = lowerText.indexOf(lowerQuery, start);
    if (idx == -1) break;
    matches.add(SearchMatch(idx, idx + query.length));
    start = idx + 1;
  }
  return matches;
}

/// 获取匹配位置的上下文文本片段
String getSnippet(String text, int matchStart, int matchEnd,
    {int contextChars = 30}) {
  final snippetStart = (matchStart - contextChars).clamp(0, text.length);
  final snippetEnd = (matchEnd + contextChars).clamp(0, text.length);
  var snippet = text.substring(snippetStart, snippetEnd);
  if (snippetStart > 0) snippet = '...$snippet';
  if (snippetEnd < text.length) snippet = '$snippet...';
  return snippet;
}

/// 构建带关键词高亮的 RichText
Widget buildHighlightedText(String text, String query,
    {TextStyle? baseStyle, int maxLines = 2, TextOverflow overflow = TextOverflow.ellipsis}) {
  if (query.isEmpty) {
    return Text(text, style: baseStyle, maxLines: maxLines, overflow: overflow);
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final spans = <TextSpan>[];
  int current = 0;

  while (current < text.length) {
    final idx = lowerText.indexOf(lowerQuery, current);
    if (idx == -1) {
      spans.add(TextSpan(text: text.substring(current), style: baseStyle));
      break;
    }
    if (idx > current) {
      spans.add(
          TextSpan(text: text.substring(current, idx), style: baseStyle));
    }
    spans.add(TextSpan(
      text: text.substring(idx, idx + query.length),
      style: (baseStyle ?? const TextStyle()).copyWith(
        backgroundColor: Colors.yellow.withValues(alpha: 0.5),
        fontWeight: FontWeight.bold,
      ),
    ));
    current = idx + query.length;
  }

  return RichText(
    text: TextSpan(children: spans),
    maxLines: maxLines,
    overflow: overflow,
  );
}
