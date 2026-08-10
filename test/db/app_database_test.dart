import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
import 'package:echobook/data/repositories/book_repository.dart';
import 'package:echobook/data/repositories/bookmark_repository.dart';
import 'package:echobook/data/repositories/export_repository.dart';
import 'package:echobook/data/repositories/progress_repository.dart';
import 'package:echobook/data/repositories/voice_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('BookRepository', () {
    test('upsert then getById round-trips a book', () async {
      final repo = BookRepository(db);
      await repo.upsert(BooksCompanion.insert(
        id: 'book-1',
        title: 'Test Book',
        format: BookFormat.epub,
        filePath: '/tmp/book.epub',
        importedAt: DateTime(2026, 1, 1),
      ));

      final book = await repo.getById('book-1');

      expect(book, isNotNull);
      expect(book!.title, 'Test Book');
      expect(book.author, 'Unknown Author');
    });

    test('deleteBook cascades progress, bookmarks and export jobs', () async {
      final books = BookRepository(db);
      final progress = ProgressRepository(db);
      final bookmarks = BookmarkRepository(db);
      final exports = ExportRepository(db);

      await books.upsert(BooksCompanion.insert(
        id: 'book-2',
        title: 'Doomed Book',
        format: BookFormat.txt,
        filePath: '/tmp/doomed.txt',
        importedAt: DateTime(2026, 1, 1),
      ));
      await progress.save(
        bookId: 'book-2',
        chapterIndex: 0,
        chapterFraction: 0.5,
        overallFraction: 0.5,
        characterOffset: 10,
      );
      await bookmarks.add(BookmarkRow(
        id: 'bm-1',
        bookId: 'book-2',
        chapterIndex: 0,
        characterOffset: 5,
        excerpt: 'excerpt',
        label: null,
        createdAt: DateTime(2026, 1, 1),
      ));
      await exports.upsert(ExportJobsCompanion.insert(
        id: 'job-1',
        bookId: 'book-2',
        voiceProfileId: 'voice-1',
        scopeType: 'book',
        scopeJson: '[]',
        format: 'wav',
        createdAt: DateTime(2026, 1, 1),
      ));

      await books.deleteBook('book-2');

      expect(await books.getById('book-2'), isNull);
      expect(await progress.get('book-2'), isNull);
      final remainingBookmarks = await db.select(db.bookmarks).get();
      expect(remainingBookmarks, isEmpty);
      final remainingExports = await db.select(db.exportJobs).get();
      expect(remainingExports, isEmpty);
    });

    test('search filters case-insensitively by title and author', () async {
      final repo = BookRepository(db);
      await repo.upsert(BooksCompanion.insert(
        id: 'b1',
        title: 'The Great Adventure',
        author: const Value('Jane Doe'),
        format: BookFormat.epub,
        filePath: '/tmp/1.epub',
        importedAt: DateTime(2026, 1, 1),
      ));
      await repo.upsert(BooksCompanion.insert(
        id: 'b2',
        title: 'Cooking Basics',
        author: const Value('John Smith'),
        format: BookFormat.epub,
        filePath: '/tmp/2.epub',
        importedAt: DateTime(2026, 1, 1),
      ));

      final results = await repo.search('great');

      expect(results.map((b) => b.id), ['b1']);
    });
  });

  group('ProgressRepository', () {
    test('save then get restores exact reading position', () async {
      final repo = ProgressRepository(db);
      await repo.save(
        bookId: 'book-3',
        chapterIndex: 2,
        chapterFraction: 0.42,
        overallFraction: 0.15,
        characterOffset: 321,
      );

      final row = await repo.get('book-3');

      expect(row, isNotNull);
      expect(row!.chapterIndex, 2);
      expect(row.chapterFraction, closeTo(0.42, 0.0001));
      expect(row.overallFraction, closeTo(0.15, 0.0001));
      expect(row.characterOffset, 321);
    });

    test('saving again for the same book overwrites, not duplicates', () async {
      final repo = ProgressRepository(db);
      await repo.save(
        bookId: 'book-4',
        chapterIndex: 0,
        chapterFraction: 0.1,
        overallFraction: 0.1,
        characterOffset: 10,
      );
      await repo.save(
        bookId: 'book-4',
        chapterIndex: 1,
        chapterFraction: 0.2,
        overallFraction: 0.3,
        characterOffset: 20,
      );

      final all = await repo.watchAll().first;
      final forBook = all.where((r) => r.bookId == 'book-4').toList();

      expect(forBook.length, 1);
      expect(forBook.first.chapterIndex, 1);
    });
  });

  group('VoiceRepository', () {
    test('setDefault ensures exactly one default profile at a time', () async {
      final repo = VoiceRepository(db);
      await repo.upsert(VoiceProfilesCompanion.insert(
        id: 'v1',
        name: 'Voice One',
        kind: VoiceKind.system,
        isDefault: const Value(true),
        createdAt: DateTime(2026, 1, 1),
      ));
      await repo.upsert(VoiceProfilesCompanion.insert(
        id: 'v2',
        name: 'Voice Two',
        kind: VoiceKind.system,
        createdAt: DateTime(2026, 1, 1),
      ));

      await repo.setDefault('v2');

      final all = await repo.getAll();
      final defaults = all.where((v) => v.isDefault).toList();
      expect(defaults.length, 1);
      expect(defaults.first.id, 'v2');
    });
  });

  group('ExportRepository', () {
    test('complete marks a job finished with output path and size', () async {
      final repo = ExportRepository(db);
      await repo.upsert(ExportJobsCompanion.insert(
        id: 'job-2',
        bookId: 'book-x',
        voiceProfileId: 'voice-x',
        scopeType: 'book',
        scopeJson: '[]',
        format: 'mp3_192',
        createdAt: DateTime(2026, 1, 1),
      ));

      await repo.complete('job-2', '/tmp/out.mp3', 12345);

      final job = (await repo.watchAll().first).firstWhere((j) => j.id == 'job-2');
      expect(job.status, ExportStatus.completed);
      expect(job.outputPath, '/tmp/out.mp3');
      expect(job.estimatedBytes, 12345);
      expect(job.progress, 1.0);
    });

    test('fail records an error message and failed status', () async {
      final repo = ExportRepository(db);
      await repo.upsert(ExportJobsCompanion.insert(
        id: 'job-3',
        bookId: 'book-x',
        voiceProfileId: 'voice-x',
        scopeType: 'current',
        scopeJson: '[0]',
        format: 'wav',
        createdAt: DateTime(2026, 1, 1),
      ));

      await repo.fail('job-3', 'synthesis crashed');

      final job = (await repo.watchAll().first).firstWhere((j) => j.id == 'job-3');
      expect(job.status, ExportStatus.failed);
      expect(job.errorMessage, 'synthesis crashed');
    });
  });
}
