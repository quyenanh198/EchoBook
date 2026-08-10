import 'package:echobook/core/theme/app_theme.dart';
import 'package:echobook/features/tts_player/providers/player_providers.dart';
import 'package:echobook/features/tts_player/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedStatePlayerController extends PlayerController {
  _FixedStatePlayerController(super.ref, PlayerState fixedState) {
    state = fixedState;
  }
}

Widget _wrap(PlayerState state) {
  return ProviderScope(
    overrides: [
      playerControllerProvider.overrideWith((ref) => _FixedStatePlayerController(ref, state)),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: MiniPlayer()),
    ),
  );
}

void main() {
  testWidgets('renders nothing when no playback is active', (tester) async {
    await tester.pumpWidget(_wrap(const PlayerState(isActive: false)));

    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.pause), findsNothing);
  });

  testWidgets('shows book/chapter title and a play icon when paused', (tester) async {
    await tester.pumpWidget(_wrap(const PlayerState(
      isActive: true,
      isPlaying: false,
      bookTitle: 'My Great Book',
      chapterTitle: 'Chapter Three',
      overallFraction: 0.4,
    )));

    expect(find.text('My Great Book'), findsOneWidget);
    expect(find.text('Chapter Three'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);
  });

  testWidgets('shows a pause icon when playing', (tester) async {
    await tester.pumpWidget(_wrap(const PlayerState(
      isActive: true,
      isPlaying: true,
      bookTitle: 'My Great Book',
      chapterTitle: 'Chapter Three',
    )));

    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });
}
