import 'package:drift/drift.dart';

import '../db/app_database.dart';

class BookmarkRepository {
  final AppDatabase _db;

  BookmarkRepository(this._db);

  Stream<List<BookmarkRow>> watchForBook(String bookId) {
    return (_db.select(_db.bookmarks)
          ..where((b) => b.bookId.equals(bookId))
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
        .watch();
  }

  Future<void> add(BookmarkRow bookmark) {
    return _db.into(_db.bookmarks).insertOnConflictUpdate(BookmarksCompanion.insert(
          id: bookmark.id,
          bookId: bookmark.bookId,
          chapterIndex: bookmark.chapterIndex,
          characterOffset: bookmark.characterOffset,
          excerpt: bookmark.excerpt,
          label: Value(bookmark.label),
          createdAt: bookmark.createdAt,
        ));
  }

  Future<void> remove(String id) {
    return (_db.delete(_db.bookmarks)..where((b) => b.id.equals(id))).go();
  }
}
