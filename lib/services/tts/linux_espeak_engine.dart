import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'espeak_params.dart';
import 'system_voice.dart';
import 'voice_engine.dart';

/// [VoiceEngine] for Linux desktop, backed by the offline `espeak-ng` CLI.
///
/// `flutter_tts` has no Linux implementation at all — it's absent from
/// `linux/flutter/generated_plugin_registrant.cc` even though every other
/// TTS-adjacent plugin used here registers fine on Linux (`record_linux`,
/// `sqlite3_flutter_libs`, ...). Every method on `FlutterTts` is a platform
/// channel call, so on Linux each one throws `MissingPluginException`
/// synchronously — and because Listen Mode drives `speak()` from an
/// unawaited loop, that exception had nowhere to go and took the whole app
/// down. `espeak-ng` is small, offline, and packaged by every major distro
/// (`apt/dnf/pacman install espeak-ng`), so it fills that gap directly. It
/// also ships genuine Vietnamese voices (`vi`, `vi-vn-x-central`,
/// `vi-vn-x-south`) out of the box with no extra language pack to install.
class LinuxEspeakEngine implements VoiceEngine {
  Process? _process;
  bool _stopRequested = false;
  String _voiceId = 'en-us';
  int _wpm = 175; // espeak-ng's own default rate == our 1.0x.
  int _pitchArg = 50; // espeak-ng's own default pitch (0..99) == our 1.0x.

  @override
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _stopRequested = false;
    Process process;
    try {
      process = await Process.start('espeak-ng', [
        '-v', _voiceId,
        '-s', '$_wpm',
        '-p', '$_pitchArg',
        '--stdin',
      ]);
    } on ProcessException catch (e) {
      throw LinuxTtsUnavailableException(
          'espeak-ng is not installed or not on PATH. Install it with your package '
          'manager (e.g. `sudo apt install espeak-ng`) to enable Listen Mode. ($e)');
    }

    _process = process;
    // Drain stdout/stderr as they arrive rather than after exit — an
    // unread pipe can fill its OS buffer and block the child process
    // mid-utterance, which would otherwise hang this whole speak() call.
    process.stdout.drain<void>();
    final stderrText = StringBuffer();
    final stderrDone = process.stderr.transform(utf8.decoder).forEach(stderrText.write);

    process.stdin.write(trimmed);
    await process.stdin.close();
    final exitCode = await process.exitCode;
    await stderrDone;
    if (identical(_process, process)) _process = null;

    if (exitCode != 0 && !_stopRequested) {
      throw LinuxTtsUnavailableException(
          'espeak-ng exited with code $exitCode.${stderrText.isEmpty ? '' : ' $stderrText'}');
    }
  }

  @override
  Future<void> pause() => stop();

  @override
  Future<void> stop() async {
    _stopRequested = true;
    _process?.kill();
    _process = null;
  }

  @override
  Future<void> setSpeed(double speed) async {
    _wpm = EspeakParams.wpmFor(speed);
  }

  @override
  Future<void> setPitch(double pitch) async {
    _pitchArg = EspeakParams.pitchArgFor(pitch);
  }

  @override
  Future<void> setVoice(SystemVoice voice) async {
    // For espeak-ng voices, `locale` carries the actual `-v` identifier
    // (e.g. "vi", "en-us") — see `getVoices()`/`parseVoicesOutput` below.
    _voiceId = voice.locale;
  }

  @override
  Future<List<SystemVoice>> getVoices() async {
    try {
      final result = await Process.run('espeak-ng', ['--voices']);
      if (result.exitCode != 0) return const [];
      return parseVoicesOutput(result.stdout.toString());
    } on ProcessException {
      return const [];
    }
  }

  /// Parses `espeak-ng --voices` output into [SystemVoice]s.
  ///
  /// Exposed as a pure function (no process spawning) so it's unit-testable
  /// against a captured fixture of the real CLI output.
  static List<SystemVoice> parseVoicesOutput(String output) {
    final lines = output.split('\n');
    final voices = <SystemVoice>[];
    for (final line in lines.skip(1)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split(RegExp(r'\s+'));
      // Columns: Pty, Language, Age/Gender, VoiceName, File, [Other Languages]
      if (parts.length < 4) continue;
      final code = parts[1];
      final displayName = parts[3].replaceAll('_', ' ');
      voices.add(SystemVoice(name: displayName, locale: code));
    }
    return voices;
  }

  @override
  void dispose() {
    _stopRequested = true;
    _process?.kill();
    _process = null;
  }
}

class LinuxTtsUnavailableException implements Exception {
  final String message;
  const LinuxTtsUnavailableException(this.message);

  @override
  String toString() => message;
}
