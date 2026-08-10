import 'package:echobook/services/export/export_estimator.dart';
import 'package:echobook/services/export/format_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('higher speed produces a shorter estimated duration', () {
    final slow = ExportEstimator.estimate(totalWords: 3000, speed: 1.0, format: ExportFormat.mp3_192);
    final fast = ExportEstimator.estimate(totalWords: 3000, speed: 2.0, format: ExportFormat.mp3_192);
    expect(fast.audioDuration, lessThan(slow.audioDuration));
  });

  test('higher bitrate produces a larger estimated file for the same audio', () {
    final low = ExportEstimator.estimate(totalWords: 3000, speed: 1.0, format: ExportFormat.mp3_128);
    final high = ExportEstimator.estimate(totalWords: 3000, speed: 1.0, format: ExportFormat.mp3_320);
    expect(high.estimatedBytes, greaterThan(low.estimatedBytes));
  });

  test('zero words estimates zero duration and size', () {
    final estimate = ExportEstimator.estimate(totalWords: 0, speed: 1.0, format: ExportFormat.wav);
    expect(estimate.audioDuration, Duration.zero);
    expect(estimate.estimatedBytes, 0);
  });

  test('generation time estimate is proportional to audio duration', () {
    final estimate = ExportEstimator.estimate(totalWords: 3000, speed: 1.0, format: ExportFormat.wav);
    expect(estimate.estimatedGenerationTime.inSeconds, lessThanOrEqualTo(estimate.audioDuration.inSeconds));
    expect(estimate.estimatedGenerationTime.inSeconds, greaterThan(0));
  });
}
