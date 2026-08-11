import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/app_messenger.dart';
import '../../../core/utils/progress_math.dart';
import '../../../core/utils/sentence_splitter.dart';
import '../../../data/db/app_database.dart';
import '../../../services/parsing/parsed_book.dart';
import '../../../services/tts/system_voice.dart';
import '../../../services/tts/voice_engine.dart';
import '../../../services/tts/voice_engine_factory.dart';

class PlayerState {
  final bool isActive;
  final bool isPlaying;
  final bool isBuffering;
  final String? bookId;
  final String bookTitle;
  final int chapterIndex;
  final String chapterTitle;
  final int chapterCount;
  final int sentenceIndex;
  final int sentenceCount;
  final String currentSentenceText;
  final double speed;
  final double pitch;
  final Duration? sleepTimerRemaining;
  final double overallFraction;
  final String? errorMessage;

  const PlayerState({
    this.isActive = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.bookId,
    this.bookTitle = '',
    this.chapterIndex = 0,
    this.chapterTitle = '',
    this.chapterCount = 0,
    this.sentenceIndex = 0,
    this.sentenceCount = 0,
    this.currentSentenceText = '',
    this.speed = 1.0,
    this.pitch = 1.0,
    this.sleepTimerRemaining,
    this.overallFraction = 0,
    this.errorMessage,
  });

  PlayerState copyWith({
    bool? isActive,
    bool? isPlaying,
    bool? isBuffering,
    String? bookId,
    String? bookTitle,
    int? chapterIndex,
    String? chapterTitle,
    int? chapterCount,
    int? sentenceIndex,
    int? sentenceCount,
    String? currentSentenceText,
    double? speed,
    double? pitch,
    Duration? sleepTimerRemaining,
    bool clearSleepTimer = false,
    double? overallFraction,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerState(
      isActive: isActive ?? this.isActive,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      chapterCount: chapterCount ?? this.chapterCount,
      sentenceIndex: sentenceIndex ?? this.sentenceIndex,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      currentSentenceText: currentSentenceText ?? this.currentSentenceText,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      sleepTimerRemaining:
          clearSleepTimer ? null : (sleepTimerRemaining ?? this.sleepTimerRemaining),
      overallFraction: overallFraction ?? this.overallFraction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives Listen Mode: speaks a book chapter-by-chapter, sentence-by-sentence
/// through a [VoiceEngine], tracking position for highlighting, progress
/// persistence, and the mini player UI.
class PlayerController extends StateNotifier<PlayerState> {
  final Ref _ref;
  final VoiceEngine _engine;

  List<ParsedChapter> _chapters = const [];
  List<Sentence> _sentences = const [];
  BookLengthIndex _lengthIndex = const BookLengthIndex([], 1);
  int _playToken = 0;
  Timer? _sleepTickTimer;

  PlayerController(this._ref, {VoiceEngine? engine})
      : _engine = engine ?? VoiceEngineFactory.create(),
        super(const PlayerState());

  List<Sentence> get currentSentences => _sentences;

  /// Reports an engine failure (missing native TTS backend, unavailable
  /// voice, etc.) as recoverable state + a SnackBar instead of letting the
  /// exception propagate uncaught, which is what used to take the whole app
  /// down when e.g. the platform's TTS plugin wasn't available.
  void _handleEngineError(Object error) {
    state = state.copyWith(isPlaying: false, errorMessage: 'Voice playback failed: $error');
    AppMessenger.showError('Voice playback failed: $error');
  }

  /// Pushes [profile]'s voice/speed/pitch onto the running engine — the one
  /// place this happens, used both when starting playback and when the
  /// user switches the default voice mid-session (see [applyVoiceProfile]),
  /// so both paths behave identically for every voice kind, including
  /// cloned ones (whose `systemVoiceId`/`systemVoiceLocale` point at their
  /// *base* system voice — see `VoiceCloneService`). Returns the
  /// speed/pitch that ended up applied, for the caller to reflect in
  /// [PlayerState]. Never catches — callers each have their own
  /// error-handling `try`/`catch` around this.
  Future<(double, double)> _applyVoiceProfileToEngine(VoiceProfileRow? profile) async {
    if (profile == null) return (state.speed, state.pitch);
    if (profile.systemVoiceId != null && profile.systemVoiceLocale != null) {
      await _engine.setVoice(
        SystemVoice(name: profile.systemVoiceId!, locale: profile.systemVoiceLocale!),
      );
    }
    await _engine.setSpeed(profile.speed);
    await _engine.setPitch(profile.pitch);
    return (profile.speed, profile.pitch);
  }

  /// Live-applies [profile] to the currently running engine without
  /// restarting playback — called when the user picks a different default
  /// voice (Voices tab → "Set as default") while Listen Mode is already
  /// active, so the switch is heard on the very next sentence instead of
  /// only after a manual stop/replay. A no-op if nothing is playing right
  /// now (the next `playFrom()` will pick up the new default anyway).
  Future<void> applyVoiceProfile(VoiceProfileRow profile) async {
    if (!state.isActive) return;
    try {
      final (speed, pitch) = await _applyVoiceProfileToEngine(profile);
      state = state.copyWith(speed: speed, pitch: pitch, clearError: true);
    } catch (e) {
      _handleEngineError(e);
    }
  }

  Future<void> playFrom({
    required String bookId,
    required String bookTitle,
    required List<ParsedChapter> chapters,
    required int chapterIndex,
    int charOffset = 0,
  }) async {
    _playToken++;
    final token = _playToken;
    try {
      await _engine.stop();

      final defaultVoice = await _ref.read(voiceRepositoryProvider).getDefault();
      final (speed, pitch) = await _applyVoiceProfileToEngine(defaultVoice);
      if (token != _playToken) return;
      await _playFromReady(
        token: token,
        bookId: bookId,
        bookTitle: bookTitle,
        chapters: chapters,
        chapterIndex: chapterIndex,
        charOffset: charOffset,
        speed: speed,
        pitch: pitch,
      );
    } catch (e) {
      if (token != _playToken) return;
      _handleEngineError(e);
    }
  }

  Future<void> _playFromReady({
    required int token,
    required String bookId,
    required String bookTitle,
    required List<ParsedChapter> chapters,
    required int chapterIndex,
    required int charOffset,
    required double speed,
    required double pitch,
  }) async {
    _chapters = chapters;
    _lengthIndex = BookLengthIndex.fromChapters(chapters);
    _loadChapterSentences(chapterIndex);
    final startSentence = SentenceSplitter.sentenceIndexAtOffset(_sentences, charOffset);

    state = state.copyWith(
      isActive: true,
      isPlaying: true,
      bookId: bookId,
      bookTitle: bookTitle,
      chapterIndex: chapterIndex,
      chapterTitle: chapters[chapterIndex].title,
      chapterCount: chapters.length,
      sentenceIndex: startSentence,
      sentenceCount: _sentences.length,
      currentSentenceText: _sentences.isNotEmpty ? _sentences[startSentence].text : '',
      speed: speed,
      pitch: pitch,
      clearError: true,
    );

    unawaited(_runLoop(token));
  }

  void _loadChapterSentences(int chapterIndex) {
    _sentences = SentenceSplitter.split(_chapters[chapterIndex].plainText);
  }

  Future<void> _runLoop(int token) async {
    while (token == _playToken) {
      if (_sentences.isEmpty) {
        final advanced = await _advanceChapter(token);
        if (!advanced) break;
        continue;
      }
      if (state.sentenceIndex >= _sentences.length) {
        final advanced = await _advanceChapter(token);
        if (!advanced) break;
        continue;
      }

      final sentence = _sentences[state.sentenceIndex];
      state = state.copyWith(currentSentenceText: sentence.text);
      try {
        await _engine.speak(sentence.text);
      } catch (e) {
        if (token != _playToken) return;
        _handleEngineError(e);
        return;
      }
      if (token != _playToken) return;
      if (!state.isPlaying) return; // paused/stopped mid-utterance

      _saveProgress(sentence.end);
      state = state.copyWith(sentenceIndex: state.sentenceIndex + 1);
    }
  }

  Future<bool> _advanceChapter(int token) async {
    final next = state.chapterIndex + 1;
    if (next >= _chapters.length) {
      state = state.copyWith(isPlaying: false);
      return false;
    }
    _loadChapterSentences(next);
    state = state.copyWith(
      chapterIndex: next,
      chapterTitle: _chapters[next].title,
      sentenceIndex: 0,
      sentenceCount: _sentences.length,
    );
    return true;
  }

  void _saveProgress(int charOffsetInChapter) {
    final bookId = state.bookId;
    if (bookId == null || _chapters.isEmpty) return;
    final chapterLen = _chapters[state.chapterIndex].plainText.length.clamp(1, 1 << 30);
    final chapterFraction = (charOffsetInChapter / chapterLen).clamp(0.0, 1.0);
    final overall = _lengthIndex.overallFraction(state.chapterIndex, chapterFraction);
    state = state.copyWith(overallFraction: overall);
    _ref.read(progressRepositoryProvider).save(
          bookId: bookId,
          chapterIndex: state.chapterIndex,
          chapterFraction: chapterFraction,
          overallFraction: overall,
          characterOffset: charOffsetInChapter,
        );
  }

  /// Best-effort engine stop — a failure here (e.g. the engine is already
  /// dead) shouldn't block the state transition the caller is making.
  Future<void> _safeStop() async {
    try {
      await _engine.stop();
    } catch (_) {
      // Ignored: we're stopping anyway, nothing meaningful to recover.
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      state = state.copyWith(isPlaying: false);
      await _safeStop();
    } else {
      state = state.copyWith(isPlaying: true);
      unawaited(_runLoop(_playToken));
    }
  }

  Future<void> stop() async {
    _playToken++;
    await _safeStop();
    _cancelSleepTimer();
    state = const PlayerState();
  }

  Future<void> skipSentence(int delta) async {
    if (_sentences.isEmpty) return;
    _playToken++;
    final token = _playToken;
    await _safeStop();

    var newIndex = state.sentenceIndex + delta;
    if (newIndex < 0) {
      if (state.chapterIndex == 0) {
        newIndex = 0;
      } else {
        _loadChapterSentences(state.chapterIndex - 1);
        state = state.copyWith(
          chapterIndex: state.chapterIndex - 1,
          chapterTitle: _chapters[state.chapterIndex - 1].title,
          sentenceCount: _sentences.length,
        );
        newIndex = (_sentences.length - 1).clamp(0, _sentences.length);
      }
    } else if (newIndex >= _sentences.length && state.chapterIndex + 1 < _chapters.length) {
      _loadChapterSentences(state.chapterIndex + 1);
      state = state.copyWith(
        chapterIndex: state.chapterIndex + 1,
        chapterTitle: _chapters[state.chapterIndex + 1].title,
        sentenceCount: _sentences.length,
      );
      newIndex = 0;
    } else {
      newIndex = newIndex.clamp(0, (_sentences.length - 1).clamp(0, 1 << 30));
    }

    state = state.copyWith(
      sentenceIndex: newIndex,
      currentSentenceText: _sentences.isNotEmpty ? _sentences[newIndex].text : '',
      isPlaying: true,
    );
    unawaited(_runLoop(token));
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    try {
      await _engine.setSpeed(speed);
    } catch (e) {
      _handleEngineError(e);
    }
  }

  Future<void> setPitch(double pitch) async {
    state = state.copyWith(pitch: pitch);
    try {
      await _engine.setPitch(pitch);
    } catch (e) {
      _handleEngineError(e);
    }
  }

  Future<void> setVoice(SystemVoice voice) async {
    try {
      await _engine.setVoice(voice);
    } catch (e) {
      _handleEngineError(e);
    }
  }

  Future<List<SystemVoice>> getSystemVoices() => _engine.getVoices();

  void setSleepTimer(Duration? duration) {
    _cancelSleepTimer();
    if (duration == null) return;
    state = state.copyWith(sleepTimerRemaining: duration);
    _sleepTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.sleepTimerRemaining;
      if (remaining == null) return;
      final next = remaining - const Duration(seconds: 1);
      if (next.isNegative || next == Duration.zero) {
        stop();
      } else {
        state = state.copyWith(sleepTimerRemaining: next);
      }
    });
  }

  void _cancelSleepTimer() {
    _sleepTickTimer?.cancel();
    _sleepTickTimer = null;
    state = state.copyWith(clearSleepTimer: true);
  }

  @override
  void dispose() {
    _cancelSleepTimer();
    try {
      _engine.dispose();
    } catch (_) {
      // Ignored: the controller is going away regardless.
    }
    super.dispose();
  }
}

final playerControllerProvider = StateNotifierProvider<PlayerController, PlayerState>((ref) {
  return PlayerController(ref);
});
