import 'dart:async';

import 'package:drift/native.dart';
import 'package:echobook/core/providers/core_providers.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
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
  // AppMessenger (used by PlayerController to report engine failures) reads
  // a GlobalKey, which needs a widgets binding even outside a widget test.
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('applyVoiceProfile — switching voices mid-session', () {
    VoiceProfileRow voiceProfile({
      required String id,
      String systemVoiceId = 'Microsoft David',
      String systemVoiceLocale = 'en-US',
      double speed = 1.0,
      double pitch = 1.0,
      String kind = VoiceKind.system,
    }) {
      return VoiceProfileRow(
        id: id,
        name: id,
        kind: kind,
        systemVoiceId: systemVoiceId,
        systemVoiceLocale: systemVoiceLocale,
        sampleAudioPath: null,
        echovoicePath: null,
        pitchShift: 0,
        speed: speed,
        pitch: pitch,
        isDefault: false,
        createdAt: DateTime(2026, 1, 1),
      );
    }

    test('is a no-op when nothing is playing — next playFrom() picks it up instead', () async {
      final controller = container.read(testProvider.notifier);

      await controller.applyVoiceProfile(voiceProfile(id: 'v1'));

      expect(fakeEngine.lastVoice, isNull);
      expect(container.read(testProvider).isActive, isFalse);
    });

    test('pushes voice/speed/pitch onto the running engine immediately, for a cloned voice too', () async {
      final controller = container.read(testProvider.notifier);
      await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
      await pump();

      // A cloned profile's systemVoiceId/systemVoiceLocale point at its
      // *base* system voice (see VoiceCloneService) — applying it should
      // work exactly the same as a plain system voice.
      final cloned = voiceProfile(
        id: 'cloned-1',
        kind: VoiceKind.cloned,
        systemVoiceId: 'vi_VN-vais1000-medium',
        systemVoiceLocale: 'vi-VN',
        speed: 1.4,
        pitch: 0.8,
      );
      await controller.applyVoiceProfile(cloned);

      expect(fakeEngine.lastVoice, const SystemVoice(name: 'vi_VN-vais1000-medium', locale: 'vi-VN'));
      expect(fakeEngine.lastSpeed, 1.4);
      expect(fakeEngine.lastPitch, 0.8);
      final state = container.read(testProvider);
      expect(state.speed, 1.4);
      expect(state.pitch, 0.8);
      expect(state.errorMessage, isNull);
    });
  });

  group('engine failures are reported, never left to crash the app', () {
    late FailingVoiceEngine failingEngine;
    late StateNotifierProvider<PlayerController, PlayerState> failingProvider;

    setUp(() {
      failingEngine = FailingVoiceEngine();
      failingProvider = StateNotifierProvider<PlayerController, PlayerState>(
        (ref) => PlayerController(ref, engine: failingEngine),
      );
    });

    test('a speak() failure mid-playback stops cleanly and records errorMessage', () async {
      final controller = container.read(failingProvider.notifier);

      // Reaches the loop and starts speaking before the engine misbehaves.
      failingEngine.throwOnSpeak = false;
      await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
      failingEngine.throwOnSpeak = true;
      failingEngine.completeNextSpeak();
      await pump();

      final state = container.read(failingProvider);
      expect(state.isPlaying, isFalse);
      expect(state.errorMessage, contains('Voice playback failed'));
    });

    test('a setVoice() failure is reported without throwing', () async {
      final controller = container.read(failingProvider.notifier);
      failingEngine.throwOnSetVoice = true;

      await controller.setVoice(const SystemVoice(name: 'x', locale: 'en'));

      expect(container.read(failingProvider).errorMessage, contains('Voice playback failed'));
    });

    test('playFrom() surfaces an engine setup failure instead of throwing', () async {
      final controller = container.read(failingProvider.notifier);
      failingEngine.throwOnStop = true;

      await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);

      final state = container.read(failingProvider);
      expect(state.isActive, isFalse);
      expect(state.errorMessage, contains('Voice playback failed'));
    });

    test('switching to a cloned voice mid-playback reports a failure without throwing', () async {
      final controller = container.read(failingProvider.notifier);
      await controller.playFrom(bookId: 'book-1', bookTitle: 'Test Book', chapters: chapters, chapterIndex: 0);
      failingEngine.throwOnSetVoice = true;

      await controller.applyVoiceProfile(VoiceProfileRow(
        id: 'cloned-1',
        name: 'My Voice',
        kind: VoiceKind.cloned,
        systemVoiceId: 'Microsoft David',
        systemVoiceLocale: 'en-US',
        sampleAudioPath: null,
        echovoicePath: null,
        pitchShift: 0,
        speed: 1.0,
        pitch: 1.0,
        isDefault: true,
        createdAt: DateTime(2026, 1, 1),
      ));

      expect(container.read(failingProvider).errorMessage, contains('Voice playback failed'));
    });
  });
}

/// Fake [VoiceEngine] whose methods can be told to throw on demand — used to
/// prove engine failures (e.g. a missing native TTS plugin) surface as
/// recoverable `PlayerState.errorMessage` instead of an uncaught exception.
class FailingVoiceEngine implements VoiceEngine {
  final List<Completer<void>> _pending = [];
  bool throwOnSpeak = false;
  bool throwOnStop = false;
  bool throwOnSetVoice = false;

  @override
  Future<void> speak(String text) {
    if (throwOnSpeak) throw Exception('engine unavailable');
    final completer = Completer<void>();
    _pending.add(completer);
    return completer.future;
  }

  void completeNextSpeak() {
    final completer = _pending.removeAt(0);
    if (!completer.isCompleted) completer.complete();
  }

  @override
  Future<void> stop() async {
    if (throwOnStop) throw Exception('stop unavailable');
    for (final c in _pending) {
      if (!c.isCompleted) c.complete();
    }
    _pending.clear();
  }

  @override
  Future<void> pause() => stop();

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  Future<void> setVoice(SystemVoice voice) async {
    if (throwOnSetVoice) throw Exception('voice unavailable');
  }

  @override
  Future<List<SystemVoice>> getVoices() async => const [];

  @override
  void dispose() {}
}
