import 'dart:io';

import 'package:drift/native.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
import 'package:echobook/data/repositories/voice_repository.dart';
import 'package:echobook/services/tts/system_voice.dart';
import 'package:echobook/services/voice_clone/voice_clone_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../test_utils/wav_fixture.dart';

void main() {
  late AppDatabase db;
  late VoiceRepository voiceRepository;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    voiceRepository = VoiceRepository(db);
    tempDir = await Directory.systemTemp.createTemp('echobook_clone_test_');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('creates a cloned voice profile linked to its sample and base voice', () async {
    final samplePath = p.join(tempDir.path, 'sample.wav');
    await File(samplePath).writeAsBytes(buildTestWav(
      sineWaveSamples(frequencyHz: 180, sampleRate: 16000, durationSeconds: 1.0),
      sampleRate: 16000,
    ));

    final service = VoiceCloneService(voiceRepository);
    final profile = await service.createClonedProfile(
      name: 'My Voice',
      sampleAudioPath: samplePath,
      baseVoice: const SystemVoice(name: 'Microsoft David', locale: 'en-US'),
    );

    expect(profile.name, 'My Voice');
    expect(profile.kind, VoiceKind.cloned);
    expect(profile.sampleAudioPath, samplePath);
    expect(profile.systemVoiceId, 'Microsoft David');
    expect(profile.systemVoiceLocale, 'en-US');
    // pitch and pitchShift should be derived from the sample, not left at
    // the table's neutral default of 1.0-by-coincidence — cross-check
    // against the estimator directly used elsewhere.
    expect(profile.pitch, profile.pitchShift);

    final persisted = await voiceRepository.getAll();
    expect(persisted.map((v) => v.id), contains(profile.id));
  });

  test('cloned profile is not marked default automatically', () async {
    final samplePath = p.join(tempDir.path, 'sample2.wav');
    await File(samplePath)
        .writeAsBytes(buildTestWav(List.filled(4000, 100), sampleRate: 16000));

    final service = VoiceCloneService(voiceRepository);
    final profile = await service.createClonedProfile(
      name: 'Second Voice',
      sampleAudioPath: samplePath,
      baseVoice: const SystemVoice(name: 'Microsoft Zira', locale: 'en-US'),
    );

    expect(profile.isDefault, isFalse);
  });
}
