import 'dart:io';
import 'dart:typed_data';

/// Minimal pure-Dart WAV (PCM) reader/writer/concatenator — enough to stitch
/// several per-chapter renders into one continuous file without needing
/// ffmpeg for the WAV-only path.
class WavTools {
  static Future<void> concatenate(List<String> inputPaths, String outputPath) async {
    if (inputPaths.isEmpty) {
      throw ArgumentError('No input WAV files to concatenate.');
    }
    if (inputPaths.length == 1) {
      await File(inputPaths.first).copy(outputPath);
      return;
    }

    _WavInfo? format;
    final dataChunks = <Uint8List>[];

    for (final path in inputPaths) {
      final bytes = await File(path).readAsBytes();
      final info = _parseWav(bytes);
      format ??= info;
      dataChunks.add(info.data);
    }

    final totalDataLength = dataChunks.fold<int>(0, (sum, d) => sum + d.length);
    final header = _buildHeader(format!, totalDataLength);

    final sink = File(outputPath).openWrite();
    sink.add(header);
    for (final chunk in dataChunks) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
  }

  static Future<Duration> wavDuration(String path) async {
    final bytes = await File(path).readAsBytes();
    final info = _parseWav(bytes);
    final bytesPerSecond = info.sampleRate * info.channels * (info.bitsPerSample ~/ 8);
    if (bytesPerSecond == 0) return Duration.zero;
    final seconds = info.data.length / bytesPerSecond;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  static _WavInfo _parseWav(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    var offset = 12;
    var channels = 1;
    var sampleRate = 44100;
    var bitsPerSample = 16;
    Uint8List? data;

    while (offset + 8 <= bytes.length) {
      final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final size = byteData.getUint32(offset + 4, Endian.little);
      final bodyStart = offset + 8;

      if (id == 'fmt ') {
        channels = byteData.getUint16(bodyStart + 2, Endian.little);
        sampleRate = byteData.getUint32(bodyStart + 4, Endian.little);
        bitsPerSample = byteData.getUint16(bodyStart + 14, Endian.little);
      } else if (id == 'data') {
        final end = (bodyStart + size).clamp(0, bytes.length);
        data = bytes.sublist(bodyStart, end);
      }

      offset = bodyStart + size + (size.isOdd ? 1 : 0);
    }

    return _WavInfo(
      channels: channels,
      sampleRate: sampleRate,
      bitsPerSample: bitsPerSample,
      data: data ?? Uint8List(0),
    );
  }

  static Uint8List _buildHeader(_WavInfo format, int dataLength) {
    final byteRate = format.sampleRate * format.channels * (format.bitsPerSample ~/ 8);
    final blockAlign = format.channels * (format.bitsPerSample ~/ 8);
    final buffer = ByteData(44);

    void writeString(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        buffer.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    buffer.setUint32(4, 36 + dataLength, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little); // PCM
    buffer.setUint16(22, format.channels, Endian.little);
    buffer.setUint32(24, format.sampleRate, Endian.little);
    buffer.setUint32(28, byteRate, Endian.little);
    buffer.setUint16(32, blockAlign, Endian.little);
    buffer.setUint16(34, format.bitsPerSample, Endian.little);
    writeString(36, 'data');
    buffer.setUint32(40, dataLength, Endian.little);

    return buffer.buffer.asUint8List();
  }
}

class _WavInfo {
  final int channels;
  final int sampleRate;
  final int bitsPerSample;
  final Uint8List data;

  const _WavInfo({
    required this.channels,
    required this.sampleRate,
    required this.bitsPerSample,
    required this.data,
  });
}
