import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../data/repositories/export_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/voice_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.shared();
  ref.onDispose(db.close);
  return db;
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(appDatabaseProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(appDatabaseProvider));
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository(ref.watch(appDatabaseProvider));
});

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  return VoiceRepository(ref.watch(appDatabaseProvider));
});

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepository(ref.watch(appDatabaseProvider));
});
