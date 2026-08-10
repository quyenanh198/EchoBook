import 'dart:async';

import 'package:drift/native.dart';
import 'package:echobook/core/providers/core_providers.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/features/tts_player/providers/player_providers.dart';
import 'package:echobook/services/parsing/parsed_book.dart';
import 'package:echobook/services/tts/system_voice.dart';
import 'package:echobook/services/tts/voice_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake [VoiceEngine] whose `speak()` calls stay pending until the test
/// explicitly completes them — makes the player's async speak-loop fully
/// deterministic instead of racing real timers.
class FakeVoiceEngine implements VoiceEngine {
  final List<String> spokenTexts = [];
  final List<Completer<void>> _pending = [];
  int stopCount = 0;
  double? lastSpeed;
  double? lastPitch;
  SystemVoice? lastVoice;

  @override
  Future<void> speak(String text) {
    spokenTexts.add(text);
    final completer = Completer<void>();
    _pending.add(completer);
    return completer.future;
  }

  /// Completes the oldest still-pending `speak()` call, as if that
  /// utterance finished naturally.
  void completeNextSpeak() {
    final completer = _pending.removeAt(0);
    if (!completer.isCompleted) completer.complete();
  }

  @override
  Future<void> stop() async {
    stopCount++;
    // Mirrors real engines: stopping mid-utterance resolves the pending
    // speak() future early (cancel handler), rather than leaving it hung.
    for (final c in _pending) {
      if (!c.isCompleted) c.complete();
    }
    _pending.clear();
  }

  @override
  Future<void> pause() => stop();

  @override
  Future<void> setSpeed(double speed) async => lastSpeed = speed;

  @override
  Future<void> setPitch(double pitch) async => lastPitch = pitch;

  @override
  Future<void> setVoice(SystemVoice voice) async => lastVoice = voice;

  @override
  Future<List<SystemVoice>> getVoices() async => const [];

  @override
  void dispose() {}
}

void main() {
  late AppDatabase db;
  late FakeVoiceEngine fakeEngine;
  late ProviderContainer container;
  late StateNotifierProvider<PlayerController, PlayerState> testProvider;

  final chapters = const [
    ParsedChapter(title: 'Ch1', plainText: 'First sentence. Second sentence.'),
    ParsedChapter(title: 'Ch2', plainText: 'Only sentence here.'),
  ];

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fakeEngine = FakeVoiceEngine();
    testProvider = StateNotifierProvider<PlayerController, PlayerState>(
      (ref) => PlayerController(ref, engine: fakeEngine),
    );
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pump() => Future(() {});

  test('playFrom activates the player and speaks the first sentence', () async {
    final controller = container.read(testProvider.notifier);

    await controller.playFrom(
      bookId: 'book-1',
      bookTitle: 'Test Book',
      chapters: chapters,
      chapterIndex: 0,
    );
    await pump();

    final state = container.read(testProvider);
    expect(state.isActive, isTrue);
    expect(state.isPlaying, isTrue);
    expect(state.sentenceCount, 2);
    expect(fakeEngine.spokenTexts, ['First sentence.']);
  });

  test('advances sentence by sentence as each utterance completes', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
    await pump();

    fakeEngine.completeNextSpeak();
    await pump();

    expect(fakeEngine.spokenTexts, ['First sentence.', 'Second sentence.']);
    expect(container.read(testProvider).sentenceIndex, 1);
  });

  test('advances to the next chapter after the last sentence of a chapter', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
    await pump();

    fakeEngine.completeNextSpeak(); // finishes "First sentence."
    await pump();
    fakeEngine.completeNextSpeak(); // finishes "Second sentence." -> advances chapter
    await pump();

    expect(container.read(testProvider).chapterIndex, 1);
    expect(fakeEngine.spokenTexts.last, 'Only sentence here.');
  });

  test('stops playback and resets state after the last chapter finishes', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 1);
    await pump();

    fakeEngine.completeNextSpeak(); // finishes the only sentence in the last chapter
    await pump();

    expect(container.read(testProvider).isPlaying, isFalse);
  });

  test('togglePlayPause stops the engine and flips isPlaying', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
    await pump();

    await controller.togglePlayPause();

    expect(container.read(testProvider).isPlaying, isFalse);
    expect(fakeEngine.stopCount, greaterThanOrEqualTo(1));
  });

  test('skipSentence(1) moves forward without waiting for completion', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
    await pump();

    await controller.skipSentence(1);
    await pump();

    expect(container.read(testProvider).sentenceIndex, 1);
    expect(fakeEngine.spokenTexts.last, 'Second sentence.');
  });

  test('skipSentence(-1) at the start of the book stays at sentence 0', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
    await pump();

    await controller.skipSentence(-1);
    await pump();

    expect(container.read(testProvider).sentenceIndex, 0);
  });

  test('setSpeed and setPitch forward to the engine and update state', () async {
    final controller = container.read(testProvider.notifier);
    await controller.setSpeed(1.75);
    await controller.setPitch(1.3);

    expect(fakeEngine.lastSpeed, 1.75);
    expect(fakeEngine.lastPitch, 1.3);
    expect(container.read(testProvider).speed, 1.75);
    expect(container.read(testProvider).pitch, 1.3);
  });

  test('stop() resets to a fresh, inactive PlayerState', () async {
    final controller = container.read(testProvider.notifier);
    await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
    await pump();

    await controller.stop();

    final state = container.read(testProvider);
    expect(state.isActive, isFalse);
    expect(state.isPlaying, isFalse);
    expect(state.bookId, isNull);
  });
}
