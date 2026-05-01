import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'app_database.dart' show AppDatabase;

class DatabaseService {
  static DatabaseService? _instance;
  late AppDatabase _database;
  bool _initialized = false;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  AppDatabase get database {
    if (!_initialized) {
      throw StateError('DatabaseService 未初始化，请先调用 init()');
    }
    return _database;
  }

  bool get isInitialized => _initialized;

  Future<void> init(String dbDirectory) async {
    if (_initialized) return;

    final dbFile = File(p.join(dbDirectory, 'novel_create.db'));
    _database = AppDatabase(NativeDatabase(dbFile));
    _initialized = true;
  }

  Future<void> dispose() async {
    if (_initialized) {
      await _database.close();
      _initialized = false;
    }
  }
}
