import 'dart:io';

import 'flutter_tts_engine.dart';
import 'linux_espeak_engine.dart';
import 'voice_engine.dart';

/// Picks the right [VoiceEngine] for live Listen Mode playback.
///
/// `flutter_tts` covers Windows, Android, iOS and macOS, but has no Linux
/// implementation — see [LinuxEspeakEngine]'s doc comment for why that used
/// to crash the app on Linux. This factory is the single place that decides
/// which backend a given platform gets, mirroring [TtsFileSynthesizerFactory]
/// for the offline-export side.
class VoiceEngineFactory {
  static VoiceEngine create() {
    if (Platform.isLinux) return LinuxEspeakEngine();
    return FlutterTtsEngine();
  }
}
