import 'dart:convert';

enum AnnotationType {
  underline,
  strikethrough,
  highlight,
}

const annotationTypeOrder = [
  AnnotationType.underline,
  AnnotationType.strikethrough,
  AnnotationType.highlight,
];

const annotationColorsHex = [
  'FF5252',
  'FF9800',
  'FFEB3B',
  '4CAF50',
  '2196F3',
  '3F51B5',
  '9C27B0',
];

class Annotation {
  final String id;
  final AnnotationType type;
  String? colorHex; // 涂色时使用
  int startOffset;
  int endOffset;

  Annotation({
    required this.id,
    required this.type,
    this.colorHex,
    required this.startOffset,
    required this.endOffset,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      type: AnnotationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnnotationType.underline,
      ),
      colorHex: json['colorHex'] as String?,
      startOffset: json['startOffset'] as int,
      endOffset: json['endOffset'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      if (colorHex != null) 'colorHex': colorHex,
      'startOffset': startOffset,
      'endOffset': endOffset,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  bool contains(int offset) => offset >= startOffset && offset < endOffset;

  Annotation copyWith({int? startOffset, int? endOffset}) {
    return Annotation(
      id: id,
      type: type,
      colorHex: colorHex,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
    );
  }
}
