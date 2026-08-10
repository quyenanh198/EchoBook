import 'package:drift/drift.dart';

import '../db/app_database.dart';

enum BookSortOrder { recent, title, author, progress }

class BookRepository {
  final AppDatabase _db;

  BookRepository(this._db);

  Stream<List<BookRow>> watchAll() => _db.select(_db.books).watch();

  Future<List<BookRow>> getAll() => _db.select(_db.books).get();

  Future<BookRow?> getById(String id) {
    return (_db.select(_db.books)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(BooksCompanion book) {
    return _db.into(_db.books).insertOnConflictUpdate(book);
  }

  Future<void> updateLastOpened(String id, DateTime when) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(lastOpenedAt: Value(when)),
    );
  }

  Future<void> deleteBook(String id) async {
    await (_db.delete(_db.books)..where((b) => b.id.equals(id))).go();
    await (_db.delete(_db.readingProgressTable)..where((r) => r.bookId.equals(id))).go();
    await (_db.delete(_db.bookmarks)..where((b) => b.bookId.equals(id))).go();
    await (_db.delete(_db.exportJobs)..where((e) => e.bookId.equals(id))).go();
  }

  Future<List<BookRow>> search(String query, {BookSortOrder order = BookSortOrder.recent}) async {
    final all = await getAll();
    final filtered = query.isEmpty
        ? all
        : all
            .where((b) =>
                b.title.toLowerCase().contains(query.toLowerCase()) ||
                b.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return filtered;
  }
}
