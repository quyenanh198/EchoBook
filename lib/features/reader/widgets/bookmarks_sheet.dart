import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/db/app_database.dart';

Future<BookmarkRow?> showBookmarksSheet(BuildContext context, WidgetRef ref, String bookId) {
  return showModalBottomSheet<BookmarkRow>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _BookmarksSheet(bookId: bookId),
  );
}

class _BookmarksSheet extends ConsumerWidget {
  final String bookId;
  const _BookmarksSheet({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(_bookmarksProvider(bookId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Bookmarks', style: Theme.of(ctx).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            Expanded(
              child: bookmarksAsync.when(
                data: (bookmarks) {
                  if (bookmarks.isEmpty) {
                    return const Center(child: Text('No bookmarks yet.'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: bookmarks.length,
                    itemBuilder: (ctx, i) {
                      final b = bookmarks[i];
                      return ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text(
                          b.excerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(DateFormat.yMMMd().add_jm().format(b.createdAt)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              ref.read(bookmarkRepositoryProvider).remove(b.id),
                        ),
                        onTap: () => Navigator.pop(ctx, b),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        );
      },
    );
  }
}

final _bookmarksProvider =
    StreamProvider.family<List<BookmarkRow>, String>((ref, bookId) {
  return ref.watch(bookmarkRepositoryProvider).watchForBook(bookId);
});
