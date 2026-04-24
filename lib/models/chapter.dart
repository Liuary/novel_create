import 'dart:convert';
import 'annotation.dart';

class Chapter {
  final String id;
  String title;
  String content;
  List<Annotation> annotations;
  String summary;
  DateTime createdAt;
  DateTime updatedAt;

  Chapter({
    required this.id,
    required this.title,
    this.content = '',
    List<Annotation>? annotations,
    this.summary = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : annotations = annotations ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'annotations': annotations.map((a) => a.toJson()).toList(),
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
