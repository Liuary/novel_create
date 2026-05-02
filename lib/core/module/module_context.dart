import '../database/app_database.dart';
import '../event/event_bus.dart';
import '../repositories/entity_link_repository.dart';

class ModuleContext {
  final AppDatabase database;
  final EventBus eventBus;
  final EntityLinkRepository linkRepo;
  final Future<String> Function(String chapterId) readChapterContent;
  final Future<void> Function(String chapterId, String content) writeChapterContent;

  ModuleContext({
    required this.database,
    required this.eventBus,
    required this.linkRepo,
    required this.readChapterContent,
    required this.writeChapterContent,
  });
}
