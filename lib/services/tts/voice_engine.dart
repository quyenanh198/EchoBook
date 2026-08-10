import 'system_voice.dart';

/// Abstraction over a live (real-time) text-to-speech engine used for
/// Listen Mode playback. Kept separate from [TtsFileSynthesizer] (used for
/// offline audio export) so either side can be swapped independently —
/// e.g. upgrading Listen Mode to a neural on-device engine later without
/// touching the export pipeline, or vice versa.
abstract class VoiceEngine {
  /// Speaks [text] and completes once speech finishes (or is stopped).
  Future<void> speak(String text);

  Future<void> pause();
  Future<void> stop();

  /// 0.5 (half speed) .. 3.0 (triple speed). 1.0 is the engine's normal rate.
  Future<void> setSpeed(double speed);

  /// 0.5 (low) .. 2.0 (high). 1.0 is the engine's normal pitch.
  Future<void> setPitch(double pitch);

  Future<void> setVoice(SystemVoice voice);

  Future<List<SystemVoice>> getVoices();

  void dispose();
}
