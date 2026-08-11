/// Shared 0.5x-3.0x speed / 0.5x-2.0x pitch -> `espeak-ng` CLI argument
/// scaling, used by both [LinuxEspeakEngine] (live playback) and
/// [LinuxEspeakFileSynthesizer] (file export) so the two can never drift
/// apart and sound different for the same voice/speed/pitch settings.
class EspeakParams {
  /// espeak-ng's own default rate (words per minute) == our 1.0x.
  static const _baseWpm = 175;

  /// espeak-ng's own default `-p` pitch (0..99 scale) == our 1.0x.
  static const _basePitchArg = 50;

  static int wpmFor(double speed) => (_baseWpm * speed.clamp(0.5, 3.0)).round().clamp(80, 500);

  static int pitchArgFor(double pitch) =>
      (_basePitchArg * pitch.clamp(0.5, 2.0)).round().clamp(0, 99);
}
