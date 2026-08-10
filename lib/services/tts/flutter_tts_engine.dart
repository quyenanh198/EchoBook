import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import 'system_voice.dart';
import 'voice_engine.dart';

/// [VoiceEngine] backed by the OS-native TTS engine via `flutter_tts`
/// (SAPI5/OneCore on Windows, AVSpeechSynthesizer on iOS, android.speech.tts
/// on Android) — fully offline on every platform.
class FlutterTtsEngine implements VoiceEngine {
  final FlutterTts _tts = FlutterTts();
  Completer<void>? _speakCompleter;

  FlutterTtsEngine() {
    _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() {
      _speakCompleter?.complete();
      _speakCompleter = null;
    });
    _tts.setCancelHandler(() {
      _speakCompleter?.complete();
      _speakCompleter = null;
    });
    _tts.setErrorHandler((msg) {
      _speakCompleter?.complete();
      _speakCompleter = null;
    });
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    _speakCompleter = Completer<void>();
    await _tts.speak(text);
    await _speakCompleter?.future;
  }

  @override
  Future<void> pause() async {
    await _tts.pause();
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _speakCompleter?.complete();
    _speakCompleter = null;
  }

  @override
  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 3.0);
    // The Windows plugin maps its input `r` to WinRT SpeakingRate = r + 0.5,
    // so passing (clamped - 0.5) reproduces `clamped` as the real multiplier
    // across the WinRT-supported 0.5x-6x range. Android/iOS TextToSpeech /
    // AVSpeechSynthesizer treat 1.0 as normal rate and accept values above
    // it directly, so we pass the multiplier through unchanged there.
    final rate = Platform.isWindows ? clamped - 0.5 : clamped;
    await _tts.setSpeechRate(rate);
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch.clamp(0.5, 2.0));
  }

  @override
  Future<void> setVoice(SystemVoice voice) async {
    await _tts.setVoice(voice.toFlutterTtsVoice());
  }

  @override
  Future<List<SystemVoice>> getVoices() async {
    final raw = await _tts.getVoices;
    final voices = <SystemVoice>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map) {
          final name = entry['name']?.toString();
          final locale = entry['locale']?.toString();
          if (name != null && locale != null) {
            voices.add(SystemVoice(name: name, locale: locale));
          }
        }
      }
    }
    return voices;
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
