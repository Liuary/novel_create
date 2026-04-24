import 'dart:convert';

class Book {
  final String id;
  String title;
  String author;
  String description;
  List<String> volumeIds;
  DateTime createdAt;
  DateTime updatedAt;

  Book({
    required this.id,
    required this.title,
    this.author = '',
    this.description = '',
    List<String>? volumeIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : volumeIds = volumeIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      volumeIds: (json['volumeIds'] as List<dynamic>?)
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
      'author': author,
      'description': description,
      'volumeIds': volumeIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
