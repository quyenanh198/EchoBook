import 'dart:io';

import 'package:path/path.dart' as p;

import 'tts_file_synthesizer.dart';

/// Offline WAV rendering on Windows via the built-in SAPI5 engine
/// (`System.Speech.Synthesis`), driven through a short PowerShell script.
///
/// This is a different (older, smaller) voice set than the WinRT/OneCore
/// voices `flutter_tts` uses for live Listen Mode playback — `flutter_tts`'s
/// Windows plugin has no `synthesizeToFile` support at all (Android/iOS
/// only), so SAPI5 is the only offline, no-extra-install path left for
/// rendering to a file on Windows. It also has no pitch API, so pitch
/// shaping (used by cloned voice profiles) only affects live playback, not
/// exported audio, on this platform — speed/rate still applies to both.
class WindowsSapiFileSynthesizer implements TtsFileSynthesizer {
  @override
  bool get isSupported => Platform.isWindows;

  @override
  Future<void> synthesizeToFile({
    required String text,
    required String outputWavPath,
    String? voiceName,
    String? voiceLocale,
    required double speed,
    required double pitch,
  }) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('WindowsSapiFileSynthesizer only runs on Windows.');
    }

    // SAPI5 Rate is an integer -10 (slowest) .. 10 (fastest), 0 = normal.
    // Linear approximation of our 0.5x-3.0x multiplier onto that range.
    final rate = ((speed - 1.0) * 10).round().clamp(-10, 10);

    final scriptPath = '${outputWavPath}_script.ps1';
    final script = _buildScript(
      text: text,
      outputWavPath: outputWavPath,
      voiceName: voiceName,
      voiceLocale: voiceLocale,
      rate: rate,
    );
    await File(scriptPath).writeAsString(script, encoding: SystemEncoding());

    try {
      final result = await Process.run(
        'powershell.exe',
        ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', scriptPath],
        stdoutEncoding: SystemEncoding(),
        stderrEncoding: SystemEncoding(),
      );
      if (result.exitCode != 0) {
        throw Exception('SAPI synthesis failed: ${result.stderr}\n${result.stdout}');
      }
      if (!await File(outputWavPath).exists()) {
        throw Exception('SAPI synthesis did not produce an output file.');
      }
    } finally {
      final scriptFile = File(scriptPath);
      if (await scriptFile.exists()) await scriptFile.delete();
    }
  }

  String _buildScript({
    required String text,
    required String outputWavPath,
    String? voiceName,
    String? voiceLocale,
    required int rate,
  }) {
    final winPath = p.absolute(outputWavPath).replaceAll('/', '\\');
    // Escape PowerShell single-quoted here-string terminator collisions by
    // never letting the text contain the literal sequence `'@` at line
    // start; safe in practice for prose, and we defensively strip it.
    final safeText = text.replaceAll("'@", "' @");

    final voiceSelect = (voiceName != null && voiceName.isNotEmpty)
        ? '''
try { \$synth.SelectVoice('${_escapeSingleQuotes(voiceName)}') } catch {
  try { \$synth.SelectVoiceByHints('NotSet', 'NotSet', 0, [System.Globalization.CultureInfo]::new('${_escapeSingleQuotes(voiceLocale ?? 'en-US')}')) } catch {}
}
'''
        : '';

    return '''
Add-Type -AssemblyName System.Speech
\$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
\$synth.Rate = $rate
\$synth.Volume = 100
$voiceSelect
\$synth.SetOutputToWaveFile('$winPath')
\$synth.Speak(@'
$safeText
'@)
\$synth.SetOutputToNull()
\$synth.Dispose()
''';
  }

  String _escapeSingleQuotes(String s) => s.replaceAll("'", "''");
}
