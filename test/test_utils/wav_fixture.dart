import 'dart:math' as math;
import 'dart:typed_data';

/// Builds a minimal valid 16-bit PCM mono WAV file in memory, for tests
/// that need a real (if tiny) WAV without depending on any TTS engine.
Uint8List buildTestWav(List<int> samples, {int sampleRate = 8000}) {
  final dataLength = samples.length * 2;
  final buffer = ByteData(44 + dataLength);

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
  buffer.setUint16(20, 1, Endian.little);
  buffer.setUint16(22, 1, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  writeString(36, 'data');
  buffer.setUint32(40, dataLength, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    buffer.setInt16(44 + i * 2, samples[i], Endian.little);
  }

  return buffer.buffer.asUint8List();
}

/// A synthetic sine wave at [frequencyHz], useful for pitch-estimation tests.
List<int> sineWaveSamples({
  required double frequencyHz,
  required int sampleRate,
  required double durationSeconds,
  int amplitude = 12000,
}) {
  final count = (sampleRate * durationSeconds).round();
  return List.generate(count, (i) {
    final t = i / sampleRate;
    final value = amplitude * math.sin(2 * math.pi * frequencyHz * t);
    return value.round();
  });
}
