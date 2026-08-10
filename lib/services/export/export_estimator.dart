import 'format_converter.dart';

class ExportEstimate {
  final Duration audioDuration;
  final int estimatedBytes;
  final Duration estimatedGenerationTime;

  const ExportEstimate({
    required this.audioDuration,
    required this.estimatedBytes,
    required this.estimatedGenerationTime,
  });
}

/// Rough, clearly-labeled-as-estimated projections shown before an export
/// starts, so users aren't surprised by file size or how long it'll take.
class ExportEstimator {
  static const _baseWordsPerMinute = 150;
  static const _sapiSampleRate = 22050;
  static const _sapiBitsPerSample = 16;

  static ExportEstimate estimate({
    required int totalWords,
    required double speed,
    required ExportFormat format,
  }) {
    final wordsPerMinute = _baseWordsPerMinute * speed;
    final minutes = wordsPerMinute <= 0 ? 0.0 : totalWords / wordsPerMinute;
    final duration = Duration(seconds: (minutes * 60).round());

    final bytes = format == ExportFormat.wav
        ? duration.inSeconds * _sapiSampleRate * (_sapiBitsPerSample ~/ 8)
        : duration.inSeconds * (format.bitrateKbps! * 1000 ~/ 8);

    // Offline SAPI/TextToSpeech rendering tends to run somewhat faster than
    // real-time playback on modern hardware.
    final generation = Duration(seconds: (duration.inSeconds * 0.8).round());

    return ExportEstimate(
      audioDuration: duration,
      estimatedBytes: bytes,
      estimatedGenerationTime: generation,
    );
  }
}
