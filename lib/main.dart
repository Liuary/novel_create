import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_service.dart';
import 'core/event/event_bus.dart';
import 'core/module/module_context.dart';
import 'core/module/module_registry.dart';
import 'core/repositories/entity_link_repository.dart';
import 'core/repositories/chapter_repository.dart';
import 'core/repositories/volume_repository.dart';
import 'modules/outline/outline_module.dart';
import 'pages/home_page.dart';
import 'services/storage_service.dart';
import 'providers/app_providers.dart' show moduleRegistryProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await DatabaseService.instance.init(StorageService.instance.dataDir);

  final db = DatabaseService.instance.database;
  final storage = StorageService.instance;
  final chapterRepo = ChapterRepository(db);
  final volumeRepo = VolumeRepository(db);

  final context = ModuleContext(
    database: db,
    eventBus: EventBus(),
    linkRepo: EntityLinkRepository(db),
    readChapterContent: (chapterId) async {
      final chapter = await chapterRepo.findById(chapterId);
      if (chapter == null) return '';
      final volume = await volumeRepo.findById(chapter.volumeId);
      if (volume == null) return '';
      final loaded = await storage.loadChapter(
          volume.bookId, volume.id, chapterId);
      return loaded?.content ?? '';
    },
    writeChapterContent: (chapterId, content) async {
      final chapter = await chapterRepo.findById(chapterId);
      if (chapter == null) return;
      final volume = await volumeRepo.findById(chapter.volumeId);
      if (volume == null) return;
      final loaded = await storage.loadChapter(
          volume.bookId, volume.id, chapterId);
      if (loaded != null) {
        loaded.content = content;
        loaded.updatedAt = DateTime.now();
        await storage.saveChapter(volume.bookId, volume.id, loaded);
      }
    },
    currentBookId: null,
  );

  final registry = ModuleRegistry();
  registry.register(OutlineModule());
  await registry.initializeAll(context);

  runApp(ProviderScope(
    overrides: [moduleRegistryProvider.overrideWithValue(registry)],
    child: const NovelCreateApp(),
  ));
}

class NovelCreateApp extends StatelessWidget {
  const NovelCreateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novel Create',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(8),
          thumbVisibility: WidgetStateProperty.all(true),
          trackVisibility: WidgetStateProperty.all(true),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(8),
          thumbVisibility: WidgetStateProperty.all(true),
          trackVisibility: WidgetStateProperty.all(true),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      locale: const Locale('zh'),
      home: const HomePage(),
    );
  }
}
