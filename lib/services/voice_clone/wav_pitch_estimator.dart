import 'dart:io';
import 'dart:typed_data';

/// Extremely lightweight, pure-Dart pitch estimate for a recorded WAV
/// sample, used to calibrate the "cloned" voice's pitch (see
/// [VoiceCloneService] for why this is a Beta approximation rather than
/// real voice cloning).
///
/// Uses a zero-crossing-rate estimate of the dominant frequency — cheap
/// and offline, at the cost of being fooled by noise/sibilance. Good
/// enough to notice "this sample sounds like a higher/lower voice than
/// average" without pulling in a real DSP/ML dependency.
class WavPitchEstimator {
  static const _assumedAverageHz = 150.0;

  /// Returns a pitch multiplier in roughly 0.7-1.6, where 1.0 means the
  /// sample's estimated pitch matches an assumed average adult voice.
  static Future<double> estimatePitchShift(String wavFilePath) async {
    try {
      final bytes = await File(wavFilePath).readAsBytes();
      final samples = _decodePcm16(bytes);
      if (samples.length < 1000) return 1.0;

      final freq = _estimateFundamentalHz(samples, _findSampleRate(bytes));
      if (freq <= 0) return 1.0;
      return (freq / _assumedAverageHz).clamp(0.7, 1.6);
    } catch (_) {
      return 1.0;
    }
  }

  static int _findSampleRate(Uint8List bytes) {
    // Standard 44-byte canonical PCM WAV header: sample rate at offset 24.
    if (bytes.length < 28) return 44100;
    final data = ByteData.sublistView(bytes);
    final rate = data.getUint32(24, Endian.little);
    return rate == 0 ? 44100 : rate;
  }

  static List<int> _decodePcm16(Uint8List bytes) {
    // Find the 'data' chunk instead of assuming a fixed 44-byte header,
    // since encoders sometimes add extra fmt fields.
    var offset = 12;
    var dataOffset = 44;
    var dataLength = bytes.length - 44;
    while (offset + 8 <= bytes.length) {
      final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final size = ByteData.sublistView(bytes, offset + 4, offset + 8).getUint32(0, Endian.little);
      if (id == 'data') {
        dataOffset = offset + 8;
        dataLength = size;
        break;
      }
      offset += 8 + size + (size.isOdd ? 1 : 0);
    }

    final end = (dataOffset + dataLength).clamp(0, bytes.length);
    final samples = <int>[];
    for (var i = dataOffset; i + 1 < end; i += 2) {
      samples.add(ByteData.sublistView(bytes, i, i + 2).getInt16(0, Endian.little));
    }
    return samples;
  }

  static double _estimateFundamentalHz(List<int> samples, int sampleRate) {
    var crossings = 0;
    for (var i = 1; i < samples.length; i++) {
      if ((samples[i - 1] < 0 && samples[i] >= 0) || (samples[i - 1] >= 0 && samples[i] < 0)) {
        crossings++;
      }
    }
    final durationSeconds = samples.length / sampleRate;
    if (durationSeconds <= 0) return 0;
    // Each full cycle produces 2 zero crossings.
    return (crossings / 2) / durationSeconds;
  }
}
