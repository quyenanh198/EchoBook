import 'dart:io';
import 'dart:typed_data';

import 'package:echobook/services/export/wav_tools.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../test_utils/wav_fixture.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('echobook_wav_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('concatenating two WAV files preserves total sample data and order', () async {
    final wavA = p.join(tempDir.path, 'a.wav');
    final wavB = p.join(tempDir.path, 'b.wav');
    final merged = p.join(tempDir.path, 'merged.wav');

    await File(wavA).writeAsBytes(buildTestWav([1, 2, 3]));
    await File(wavB).writeAsBytes(buildTestWav([4, 5]));

    await WavTools.concatenate([wavA, wavB], merged);

    final mergedBytes = await File(merged).readAsBytes();
    final byteData = ByteData.sublistView(mergedBytes);

    // 44-byte header + (3 + 2) samples * 2 bytes = 54 bytes total.
    expect(mergedBytes.length, 44 + 10);

    final samples = <int>[];
    for (var i = 44; i < mergedBytes.length; i += 2) {
      samples.add(byteData.getInt16(i, Endian.little));
    }
    expect(samples, [1, 2, 3, 4, 5]);
  });

  test('concatenating a single file just copies it', () async {
    final wavA = p.join(tempDir.path, 'a.wav');
    final merged = p.join(tempDir.path, 'merged.wav');
    final original = buildTestWav([9, 8, 7]);
    await File(wavA).writeAsBytes(original);

    await WavTools.concatenate([wavA], merged);

    expect(await File(merged).readAsBytes(), original);
  });

  test('throws for an empty input list', () {
    expect(() => WavTools.concatenate([], 'out.wav'), throwsArgumentError);
  });

  test('wavDuration reflects sample count and sample rate', () async {
    final wavPath = p.join(tempDir.path, 'dur.wav');
    // 8000 Hz, 8000 samples = 1 second.
    await File(wavPath).writeAsBytes(buildTestWav(List.filled(8000, 0), sampleRate: 8000));

    final duration = await WavTools.wavDuration(wavPath);

    expect(duration.inMilliseconds, closeTo(1000, 5));
  });
}
