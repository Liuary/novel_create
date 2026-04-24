import 'dart:convert';

class Volume {
  final String id;
  String title;
  String summary;
  List<String> chapterIds;
  DateTime createdAt;
  DateTime updatedAt;

  Volume({
    required this.id,
    required this.title,
    this.summary = '',
    List<String>? chapterIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : chapterIds = chapterIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      chapterIds: (json['chapterIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
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
      'summary': summary,
      'chapterIds': chapterIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
