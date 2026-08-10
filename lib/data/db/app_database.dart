import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Books,
  ReadingProgressTable,
  Bookmarks,
  VoiceProfiles,
  ExportJobs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static AppDatabase? _instance;

  /// Shared singleton used by the app. Tests should construct their own
  /// [AppDatabase] with an in-memory executor instead.
  factory AppDatabase.shared() {
    return _instance ??= AppDatabase();
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'echobook.sqlite'));
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      return NativeDatabase.createInBackground(file);
    });
  }
}
