import 'package:drift/drift.dart';

import '../db/app_database.dart';

class ProgressRepository {
  final AppDatabase _db;

  ProgressRepository(this._db);

  Stream<List<ReadingProgressRow>> watchAll() {
    return _db.select(_db.readingProgressTable).watch();
  }

  Stream<ReadingProgressRow?> watch(String bookId) {
    return (_db.select(_db.readingProgressTable)..where((r) => r.bookId.equals(bookId)))
        .watchSingleOrNull();
  }

  Future<ReadingProgressRow?> get(String bookId) {
    return (_db.select(_db.readingProgressTable)..where((r) => r.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  Future<void> save({
    required String bookId,
    required int chapterIndex,
    required double chapterFraction,
    required double overallFraction,
    required int characterOffset,
  }) {
    return _db.into(_db.readingProgressTable).insertOnConflictUpdate(
          ReadingProgressTableCompanion(
            bookId: Value(bookId),
            chapterIndex: Value(chapterIndex),
            chapterFraction: Value(chapterFraction),
            overallFraction: Value(overallFraction),
            characterOffset: Value(characterOffset),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
