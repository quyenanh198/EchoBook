import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../services/import/import_service.dart';

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(ref.watch(bookRepositoryProvider));
});

final booksStreamProvider = StreamProvider<List<BookRow>>((ref) {
  return ref.watch(bookRepositoryProvider).watchAll();
});

final progressStreamProvider = StreamProvider<List<ReadingProgressRow>>((ref) {
  return ref.watch(progressRepositoryProvider).watchAll();
});

final librarySearchQueryProvider = StateProvider<String>((ref) => '');
final librarySortOrderProvider = StateProvider<BookSortOrder>((ref) => BookSortOrder.recent);

/// Combined, filtered and sorted view of the library — the single source
/// the Library screen renders from.
final visibleBooksProvider = Provider<List<BookRow>>((ref) {
  final books = ref.watch(booksStreamProvider).valueOrNull ?? const [];
  final progress = ref.watch(progressStreamProvider).valueOrNull ?? const [];
  final progressByBook = {for (final p in progress) p.bookId: p.overallFraction};

  final query = ref.watch(librarySearchQueryProvider).trim().toLowerCase();
  final order = ref.watch(librarySortOrderProvider);

  var filtered = query.isEmpty
      ? [...books]
      : books
          .where((b) =>
              b.title.toLowerCase().contains(query) || b.author.toLowerCase().contains(query))
          .toList();

  switch (order) {
    case BookSortOrder.recent:
      filtered.sort((a, b) {
        final aDate = a.lastOpenedAt ?? a.importedAt;
        final bDate = b.lastOpenedAt ?? b.importedAt;
        return bDate.compareTo(aDate);
      });
      break;
    case BookSortOrder.title:
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case BookSortOrder.author:
      filtered.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
      break;
    case BookSortOrder.progress:
      filtered.sort((a, b) =>
          (progressByBook[b.id] ?? 0).compareTo(progressByBook[a.id] ?? 0));
      break;
  }

  return filtered;
});

final bookProgressProvider = Provider.family<double, String>((ref, bookId) {
  final progress = ref.watch(progressStreamProvider).valueOrNull ?? const [];
  for (final p in progress) {
    if (p.bookId == bookId) return p.overallFraction.clamp(0, 1);
  }
  return 0.0;
});
