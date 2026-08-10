import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/book_paths.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/book_repository.dart';
import '../../shell/shell_providers.dart';
import '../import/import_controller.dart';
import '../providers/library_providers.dart';
import '../widgets/book_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _dragging = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openBook(BookRow book) async {
    await ref.read(bookRepositoryProvider).updateLastOpened(book.id, DateTime.now());
    ref.read(activeBookIdProvider.notifier).state = book.id;
    ref.read(currentTabProvider.notifier).state = 1;
  }

  Future<void> _deleteBook(BookRow book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text(
          '"${book.title}" and all of its reading progress, bookmarks and generated audio will be permanently deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(bookRepositoryProvider).deleteBook(book.id);
    final paths = await BookPaths.forBook(book.id);
    await paths.deleteAll();

    if (ref.read(activeBookIdProvider) == book.id) {
      ref.read(activeBookIdProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(visibleBooksProvider);
    final sortOrder = ref.watch(librarySortOrderProvider);
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        final paths = details.files.map((f) => f.path).toList();
        await ImportController.importPaths(context, ref, paths);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          actions: [
            PopupMenuButton<BookSortOrder>(
              icon: const Icon(Icons.sort),
              initialValue: sortOrder,
              onSelected: (v) => ref.read(librarySortOrderProvider.notifier).state = v,
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: BookSortOrder.recent, child: Text('Recent')),
                PopupMenuItem(value: BookSortOrder.title, child: Text('Title')),
                PopupMenuItem(value: BookSortOrder.author, child: Text('Author')),
                PopupMenuItem(value: BookSortOrder.progress, child: Text('Progress')),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => ref.read(librarySearchQueryProvider.notifier).state = v,
                    decoration: const InputDecoration(
                      hintText: 'Search by title or author',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: books.isEmpty
                      ? _EmptyLibrary(hasQuery: ref.watch(librarySearchQueryProvider).isNotEmpty)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = (constraints.maxWidth / 170).floor().clamp(2, 8);
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.58,
                              ),
                              itemCount: books.length,
                              itemBuilder: (context, i) {
                                final book = books[i];
                                return BookCard(
                                  book: book,
                                  onTap: () => _openBook(book),
                                  onDelete: () => _deleteBook(book),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            if (_dragging)
              Positioned.fill(
                child: Container(
                  color: surfaces.background.withValues(alpha: 0.9),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_download_outlined,
                            size: 48, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        const Text('Drop ebook files to import'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => ImportController.pickAndImport(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Import Ebook'),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final bool hasQuery;
  const _EmptyLibrary({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, size: 64, color: surfaces.textSecondary),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No books match your search' : 'Your library is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try a different title or author.'
                  : 'Import an EPUB, PDF or TXT file to get started.\nDrag & drop files here, or use the button below.',
              textAlign: TextAlign.center,
              style: TextStyle(color: surfaces.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
