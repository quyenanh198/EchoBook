import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Spawns and stops the local EchoBook AI Server (`ai_server/`, a Python
/// FastAPI process bundled as `EchoBookAIServer.exe` next to the Flutter
/// binary — see `package_windows.bat`) on Windows only, the only platform
/// this build packages it for.
///
/// On every other platform — and on Windows when the exe simply isn't
/// present, e.g. running from `flutter run` in development without having
/// built/copied it — this is a silent no-op: voice cloning falls back to
/// the existing offline pitch-shift approximation instead of a real
/// embedding (see `VoiceCloneService`). Nothing about the rest of the app
/// depends on this process being alive.
class AiServerManager {
  Process? _process;
  StreamSubscription<List<int>>? _stdoutSub;
  StreamSubscription<List<int>>? _stderrSub;

  Future<void> start() async {
    if (!Platform.isWindows || _process != null) return;

    final exePath = p.join(p.dirname(Platform.resolvedExecutable), 'EchoBookAIServer.exe');
    if (!await File(exePath).exists()) return;

    try {
      final process = await Process.start(exePath, [], runInShell: false);
      _process = process;
      // Drain stdout/stderr so the child never blocks on a full pipe
      // buffer; EchoBook doesn't need to surface its logs.
      _stdoutSub = process.stdout.listen((_) {});
      _stderrSub = process.stderr.listen((_) {});
    } catch (_) {
      _process = null;
    }
  }

  void stop() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    _process?.kill();
    _process = null;
  }
}
