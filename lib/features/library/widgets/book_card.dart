import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/db/app_database.dart';
import '../providers/library_providers.dart';

class BookCard extends ConsumerWidget {
  final BookRow book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(bookProgressProvider(book.id));
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      onTap: onTap,
      onLongPress: () => _showActions(context),
      child: Container(
        decoration: BoxDecoration(
          color: surfaces.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: surfaces.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Cover(book: book)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: surfaces.border,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Open'),
              onTap: () {
                Navigator.pop(ctx);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete book'),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final BookRow book;
  const _Cover({required this.book});

  @override
  Widget build(BuildContext context) {
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;
    if (book.coverPath != null && File(book.coverPath!).existsSync()) {
      return Image.file(File(book.coverPath!), fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      color: surfaces.surfaceElevated,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Text(
        book.title,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: surfaces.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
