/// Renders text to an offline WAV file — the building block for Audio
/// Export (as opposed to [VoiceEngine], which is for live Listen Mode
/// playback). Kept as a separate abstraction because the platform APIs for
/// "speak now" and "render to file" are frequently different engines
/// entirely (see the Windows implementation).
abstract class TtsFileSynthesizer {
  /// Synthesizes [text] to a 16-bit PCM WAV file at [outputWavPath].
  ///
  /// [voiceName]/[voiceLocale] are best-effort hints — if the exact voice
  /// isn't available to this synthesizer, it falls back to the closest
  /// match it can find rather than failing.
  Future<void> synthesizeToFile({
    required String text,
    required String outputWavPath,
    String? voiceName,
    String? voiceLocale,
    required double speed,
    required double pitch,
  });

  /// Whether this platform can export audio at all.
  bool get isSupported;
}
