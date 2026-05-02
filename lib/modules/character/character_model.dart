import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class Character {
  final String id;
  final String name;
  final String aliases;
  final List<String> personalityTagsList;
  final String appearance;
  final String background;
  final String currentStatus;
  final String? locationId;
  final bool isDead;
  final String? bookId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.name,
    this.aliases = '',
    this.personalityTagsList = const [],
    this.appearance = '',
    this.background = '',
    this.currentStatus = '',
    this.locationId,
    this.isDead = false,
    this.bookId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Character.fromDb(DbCharacter db) => Character(
        id: db.id,
        name: db.name,
        aliases: db.aliases,
        personalityTagsList:
            db.personalityTags.isEmpty ? [] : db.personalityTags.split(','),
        appearance: db.appearance,
        background: db.background,
        currentStatus: db.currentStatus,
        locationId: db.locationId,
        isDead: db.isDead,
        bookId: db.bookId,
        createdAt: db.createdAt,
        updatedAt: db.updatedAt,
      );

  CharactersCompanion toCompanion() => CharactersCompanion(
        id: Value(id),
        name: Value(name),
        aliases: Value(aliases),
        personalityTags: Value(personalityTagsList.join(',')),
        appearance: Value(appearance),
        background: Value(background),
        currentStatus: Value(currentStatus),
        locationId: Value(locationId),
        isDead: Value(isDead),
        bookId: Value(bookId),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );

  Character copyWith({
    String? name,
    String? aliases,
    List<String>? personalityTagsList,
    String? appearance,
    String? background,
    String? currentStatus,
    String? locationId,
    bool? isDead,
    String? bookId,
  }) =>
      Character(
        id: id,
        name: name ?? this.name,
        aliases: aliases ?? this.aliases,
        personalityTagsList: personalityTagsList ?? this.personalityTagsList,
        appearance: appearance ?? this.appearance,
        background: background ?? this.background,
        currentStatus: currentStatus ?? this.currentStatus,
        locationId: locationId ?? this.locationId,
        isDead: isDead ?? this.isDead,
        bookId: bookId ?? this.bookId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class ChapterLog {
  final String id;
  final String characterId;
  final String chapterId;
  final String summary;
  final String statusChangedFrom;
  final String statusChangedTo;
  final int sortOrder;

  const ChapterLog({
    required this.id,
    required this.characterId,
    required this.chapterId,
    this.summary = '',
    this.statusChangedFrom = '',
    this.statusChangedTo = '',
    this.sortOrder = 0,
  });

  factory ChapterLog.fromDb(DbCharacterChapterLog db) => ChapterLog(
        id: db.id,
        characterId: db.characterId,
        chapterId: db.chapterId,
        summary: db.summary,
        statusChangedFrom: db.statusChangedFrom,
        statusChangedTo: db.statusChangedTo,
        sortOrder: db.sortOrder,
      );

  CharacterChapterLogsCompanion toCompanion() =>
      CharacterChapterLogsCompanion(
        id: Value(id),
        characterId: Value(characterId),
        chapterId: Value(chapterId),
        summary: Value(summary),
        statusChangedFrom: Value(statusChangedFrom),
        statusChangedTo: Value(statusChangedTo),
        sortOrder: Value(sortOrder),
      );
}
