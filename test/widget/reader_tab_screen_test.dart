import 'package:echobook/core/theme/app_theme.dart';
import 'package:echobook/features/reader/screens/reader_tab_screen.dart';
import 'package:echobook/features/shell/shell_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows an empty state with no book open, and switches to Library on tap', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Start on a different tab so the tap assertion below is meaningful.
    container.read(currentTabProvider.notifier).state = 2;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const ReaderTabScreen(),
        ),
      ),
    );

    expect(find.text('No book open'), findsOneWidget);
    expect(container.read(currentTabProvider), 2);

    await tester.tap(find.text('Go to Library'));
    await tester.pump();

    expect(container.read(currentTabProvider), 0);
  });
}
