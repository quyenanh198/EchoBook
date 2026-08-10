import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:echobook/core/providers/core_providers.dart';
import 'package:echobook/core/theme/app_theme.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
import 'package:echobook/features/library/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows title, author and progress percentage', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final book = BookRow(
      id: 'b1',
      title: 'The Long Title Of A Book',
      author: 'Some Author',
      format: BookFormat.epub,
      filePath: '/tmp/x.epub',
      coverPath: null,
      chapterCount: 5,
      wordCount: 1000,
      importedAt: DateTime(2026, 1, 1),
      lastOpenedAt: null,
      contentCachePath: null,
    );

    await db.into(db.readingProgressTable).insertOnConflictUpdate(
          ReadingProgressTableCompanion.insert(
            bookId: book.id,
            chapterFraction: const Value(0.42),
            overallFraction: const Value(0.42),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

    var tapped = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: BookCard(
              book: book,
              onTap: () => tapped = true,
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Appears twice: once as the placeholder cover text (no cover image
    // set), once as the title label below the cover.
    expect(find.text('The Long Title Of A Book'), findsNWidgets(2));
    expect(find.text('Some Author'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);

    await tester.tap(find.byType(BookCard));
    expect(tapped, isTrue);

    // Unmount before the test ends so Drift's stream-query cleanup timer
    // fires during this test's own pump rather than leaking into the next
    // test (it uses a zero-duration Timer under the hood).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
