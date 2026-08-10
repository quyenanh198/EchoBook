import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../shell/shell_providers.dart';
import 'reader_screen.dart';

class ReaderTabScreen extends ConsumerWidget {
  const ReaderTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookId = ref.watch(activeBookIdProvider);
    if (bookId == null) {
      final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;
      return Scaffold(
        appBar: AppBar(title: const Text('Reader')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined, size: 64, color: surfaces.textSecondary),
                const SizedBox(height: 16),
                Text('No book open', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Open a book from your Library to start reading.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: surfaces.textSecondary),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.library_books_outlined),
                  label: const Text('Go to Library'),
                  onPressed: () => ref.read(currentTabProvider.notifier).state = 0,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ReaderScreen(key: ValueKey(bookId), bookId: bookId);
  }
}
