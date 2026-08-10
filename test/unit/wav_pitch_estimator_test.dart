import 'dart:io';

import 'package:echobook/services/voice_clone/wav_pitch_estimator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../test_utils/wav_fixture.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('echobook_pitch_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('a higher-frequency tone yields a higher pitch shift than a lower one', () async {
    const sampleRate = 16000;
    final lowPath = p.join(tempDir.path, 'low.wav');
    final highPath = p.join(tempDir.path, 'high.wav');

    await File(lowPath).writeAsBytes(buildTestWav(
      sineWaveSamples(frequencyHz: 100, sampleRate: sampleRate, durationSeconds: 1.0),
      sampleRate: sampleRate,
    ));
    await File(highPath).writeAsBytes(buildTestWav(
      sineWaveSamples(frequencyHz: 250, sampleRate: sampleRate, durationSeconds: 1.0),
      sampleRate: sampleRate,
    ));

    final lowShift = await WavPitchEstimator.estimatePitchShift(lowPath);
    final highShift = await WavPitchEstimator.estimatePitchShift(highPath);

    expect(highShift, greaterThan(lowShift));
  });

  test('pitch shift is clamped to a sane range', () async {
    const sampleRate = 16000;
    final extremePath = p.join(tempDir.path, 'extreme.wav');
    await File(extremePath).writeAsBytes(buildTestWav(
      sineWaveSamples(frequencyHz: 4000, sampleRate: sampleRate, durationSeconds: 1.0),
      sampleRate: sampleRate,
    ));

    final shift = await WavPitchEstimator.estimatePitchShift(extremePath);

    expect(shift, inInclusiveRange(0.7, 1.6));
  });

  test('missing file falls back to neutral pitch instead of throwing', () async {
    final shift = await WavPitchEstimator.estimatePitchShift(
      p.join(tempDir.path, 'does_not_exist.wav'),
    );
    expect(shift, 1.0);
  });

  test('very short sample falls back to neutral pitch', () async {
    final shortPath = p.join(tempDir.path, 'short.wav');
    await File(shortPath).writeAsBytes(buildTestWav([1, 2, 3]));

    final shift = await WavPitchEstimator.estimatePitchShift(shortPath);

    expect(shift, 1.0);
  });
}
