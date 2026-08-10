import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/db/app_database.dart';
import '../../../services/parsing/content_cache.dart';
import '../../../services/parsing/parsed_book.dart';

/// Loads the cached, already-parsed chapter text for a book (written once at
/// import time) so opening a book never re-parses the source EPUB/PDF.
final chaptersProvider = FutureProvider.family<List<ParsedChapter>, String>((ref, bookId) async {
  final book = await ref.watch(bookRepositoryProvider).getById(bookId);
  if (book == null || book.contentCachePath == null) return const [];
  return ContentCache.read(book.contentCachePath!);
});

class ReaderInitData {
  final BookRow book;
  final List<ParsedChapter> chapters;
  final ReadingProgressRow? progress;

  const ReaderInitData({required this.book, required this.chapters, this.progress});
}

/// Everything the Reader screen needs to render its very first frame in one
/// shot: the book row, its cached chapters, and any previously saved
/// position to resume from.
final readerInitProvider = FutureProvider.family<ReaderInitData, String>((ref, bookId) async {
  final book = await ref.watch(bookRepositoryProvider).getById(bookId);
  if (book == null) {
    throw StateError('Book not found: $bookId');
  }
  final chapters =
      book.contentCachePath != null ? await ContentCache.read(book.contentCachePath!) : <ParsedChapter>[];
  final progress = await ref.watch(progressRepositoryProvider).get(bookId);
  return ReaderInitData(book: book, chapters: chapters, progress: progress);
});
