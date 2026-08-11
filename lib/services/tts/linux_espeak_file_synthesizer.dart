import 'dart:io';

import 'espeak_params.dart';
import 'tts_file_synthesizer.dart';

/// Offline WAV rendering on Linux via the `espeak-ng` CLI — the same engine
/// [LinuxEspeakEngine] (in `linux_espeak_engine.dart`) uses for live Listen
/// Mode playback, so a voice picked in the Voices tab renders identically
/// here. See that file's doc comment for why Linux needs its own backend
/// instead of `flutter_tts` (which has no Linux implementation at all).
class LinuxEspeakFileSynthesizer implements TtsFileSynthesizer {
  @override
  bool get isSupported => Platform.isLinux;

  @override
  Future<void> synthesizeToFile({
    required String text,
    required String outputWavPath,
    String? voiceName,
    String? voiceLocale,
    required double speed,
    required double pitch,
  }) async {
    if (!Platform.isLinux) {
      throw UnsupportedError('LinuxEspeakFileSynthesizer only runs on Linux.');
    }

    // `voiceLocale` carries the actual espeak-ng `-v` identifier for voices
    // this app lists (see LinuxEspeakEngine.parseVoicesOutput) — fall back
    // to English if the profile predates that convention or was left blank.
    final voiceId = (voiceLocale != null && voiceLocale.isNotEmpty) ? voiceLocale : 'en-us';
    final wpm = EspeakParams.wpmFor(speed);
    final pitchArg = EspeakParams.pitchArgFor(pitch);

    Process process;
    try {
      process = await Process.start('espeak-ng', [
        '-v', voiceId,
        '-s', '$wpm',
        '-p', '$pitchArg',
        '-w', outputWavPath,
        '--stdin',
      ]);
    } on ProcessException catch (e) {
      throw Exception(
          'espeak-ng is not installed or not on PATH. Install it with your package '
          'manager (e.g. `sudo apt install espeak-ng`) to enable audio export. ($e)');
    }

    process.stdout.drain<void>();
    process.stderr.drain<void>();
    process.stdin.write(text);
    await process.stdin.close();
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception('espeak-ng exited with code $exitCode while rendering "$outputWavPath".');
    }
    if (!await File(outputWavPath).exists()) {
      throw Exception('espeak-ng did not produce an output file.');
    }
  }
}
