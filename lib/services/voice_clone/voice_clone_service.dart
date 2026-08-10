import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/voice_repository.dart';
import '../tts/system_voice.dart';
import 'wav_pitch_estimator.dart';

/// Turns a recorded voice sample into a saved [VoiceProfile].
///
/// **Architecture note (Beta):** EchoBook is fully offline, and genuine
/// neural voice cloning (e.g. Coqui XTTS) needs a multi-hundred-MB model and
/// a GPU to run at usable speed — not realistic to bundle or run on an
/// average phone/laptop today. Until that trade-off changes, "cloning" here
/// means: keep using the device's real TTS engine, but personalize it by
/// picking a base system voice and nudging its pitch to roughly match the
/// sample the user recorded. It is clearly labeled Beta in the UI so users
/// don't expect their actual voice/timbre to come out.
///
/// The upgrade path is intentionally isolated here: swapping in a real
/// on-device cloning model later only means replacing this class's
/// implementation — [VoiceProfile] already has `sampleAudioPath` stored for
/// that future model to train/embed from, and every caller only depends on
/// the resulting [VoiceProfile] row, never on how it was produced.
class VoiceCloneService {
  final VoiceRepository _voiceRepository;
  static const _uuid = Uuid();

  VoiceCloneService(this._voiceRepository);

  Future<VoiceProfileRow> createClonedProfile({
    required String name,
    required String sampleAudioPath,
    required SystemVoice baseVoice,
  }) async {
    final pitchShift = await WavPitchEstimator.estimatePitchShift(sampleAudioPath);

    final id = _uuid.v4();
    await _voiceRepository.upsert(VoiceProfilesCompanion.insert(
      id: id,
      name: name,
      kind: VoiceKind.cloned,
      systemVoiceId: Value(baseVoice.name),
      systemVoiceLocale: Value(baseVoice.locale),
      sampleAudioPath: Value(sampleAudioPath),
      pitchShift: Value(pitchShift),
      pitch: Value(pitchShift),
      createdAt: DateTime.now(),
    ));

    final all = await _voiceRepository.getAll();
    return all.firstWhere((v) => v.id == id);
  }
}
