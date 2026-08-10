import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import 'tts_file_synthesizer.dart';

/// Offline WAV rendering on Android/iOS via `flutter_tts`'s native
/// `synthesizeToFile`, which those two platforms support directly (unlike
/// Windows — see [WindowsSapiFileSynthesizer]).
class MobileFlutterTtsFileSynthesizer implements TtsFileSynthesizer {
  @override
  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  @override
  Future<void> synthesizeToFile({
    required String text,
    required String outputWavPath,
    String? voiceName,
    String? voiceLocale,
    required double speed,
    required double pitch,
  }) async {
    if (!isSupported) {
      throw UnsupportedError('MobileFlutterTtsFileSynthesizer only runs on Android/iOS.');
    }

    final tts = FlutterTts();
    try {
      if (voiceName != null && voiceLocale != null) {
        await tts.setVoice({'name': voiceName, 'locale': voiceLocale});
      }
      await tts.setSpeechRate(speed.clamp(0.5, 3.0));
      await tts.setPitch(pitch.clamp(0.5, 2.0));
      await tts.synthesizeToFile(text, outputWavPath, true);

      // synthesizeToFile's platform channel result doesn't strictly
      // guarantee the file is flushed to disk the instant it resolves on
      // every OEM build; give it a brief grace window.
      for (var i = 0; i < 10; i++) {
        if (await File(outputWavPath).exists()) return;
        await Future.delayed(const Duration(milliseconds: 300));
      }
      throw Exception('Synthesis did not produce an output file.');
    } finally {
      await tts.stop();
    }
  }
}
