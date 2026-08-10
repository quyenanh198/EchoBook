import 'dart:io';

/// Output container/codec choices exposed in the Export screen.
enum ExportFormat { mp3_128, mp3_192, mp3_320, m4a, wav }

extension ExportFormatX on ExportFormat {
  String get extension => switch (this) {
        ExportFormat.mp3_128 || ExportFormat.mp3_192 || ExportFormat.mp3_320 => 'mp3',
        ExportFormat.m4a => 'm4a',
        ExportFormat.wav => 'wav',
      };

  String get label => switch (this) {
        ExportFormat.mp3_128 => 'MP3 · 128 kbps',
        ExportFormat.mp3_192 => 'MP3 · 192 kbps',
        ExportFormat.mp3_320 => 'MP3 · 320 kbps',
        ExportFormat.m4a => 'M4A (AAC)',
        ExportFormat.wav => 'WAV (uncompressed)',
      };

  int? get bitrateKbps => switch (this) {
        ExportFormat.mp3_128 => 128,
        ExportFormat.mp3_192 => 192,
        ExportFormat.mp3_320 => 320,
        ExportFormat.m4a => 192,
        ExportFormat.wav => null,
      };
}

/// Converts a rendered WAV file to the user's requested output format.
///
/// EchoBook has no bundled audio codec (ffmpeg_kit is Android/iOS-only and
/// abandoned upstream; there is no pure-Dart MP3/AAC encoder worth trusting
/// offline). Instead, if a system `ffmpeg` binary is available on PATH, it's
/// used for the conversion; otherwise the export falls back to WAV and the
/// UI tells the user why, with a pointer to install ffmpeg for compressed
/// output. This keeps the offline-first promise honest: nothing here ever
/// reaches the network, it just optionally shells out to a tool the user
/// already has.
class FormatConverter {
  static Future<bool> get ffmpegAvailable async {
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Converts [wavPath] to [outputPath] in [format]. Returns the actual
  /// output path used (falls back to a `.wav` sibling of [outputPath] if
  /// ffmpeg isn't available and [format] isn't already wav).
  static Future<String> convert({
    required String wavPath,
    required String outputPath,
    required ExportFormat format,
  }) async {
    if (format == ExportFormat.wav) {
      if (wavPath != outputPath) await File(wavPath).copy(outputPath);
      return outputPath;
    }

    if (!await ffmpegAvailable) {
      final fallback = outputPath.replaceAll(RegExp(r'\.\w+$'), '.wav');
      await File(wavPath).copy(fallback);
      return fallback;
    }

    final args = <String>['-y', '-i', wavPath];
    if (format == ExportFormat.m4a) {
      args.addAll(['-c:a', 'aac', '-b:a', '${format.bitrateKbps}k']);
    } else {
      args.addAll(['-c:a', 'libmp3lame', '-b:a', '${format.bitrateKbps}k']);
    }
    args.add(outputPath);

    final result = await Process.run('ffmpeg', args);
    if (result.exitCode != 0) {
      throw Exception('ffmpeg conversion failed: ${result.stderr}');
    }
    return outputPath;
  }
}
