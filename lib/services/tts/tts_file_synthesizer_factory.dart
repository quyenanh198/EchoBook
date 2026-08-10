import 'dart:io';

import 'linux_espeak_file_synthesizer.dart';
import 'mobile_flutter_tts_file_synthesizer.dart';
import 'tts_file_synthesizer.dart';
import 'windows_sapi_file_synthesizer.dart';

class UnsupportedExportPlatformException implements Exception {
  @override
  String toString() =>
      'Audio export is not available on this platform yet (supported: Windows, Android, iOS, Linux).';
}

class TtsFileSynthesizerFactory {
  static TtsFileSynthesizer create() {
    if (Platform.isWindows) return WindowsSapiFileSynthesizer();
    if (Platform.isAndroid || Platform.isIOS) return MobileFlutterTtsFileSynthesizer();
    if (Platform.isLinux) return LinuxEspeakFileSynthesizer();
    throw UnsupportedExportPlatformException();
  }
}
