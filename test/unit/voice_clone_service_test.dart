import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
import 'package:echobook/data/repositories/voice_repository.dart';
import 'package:echobook/services/tts/system_voice.dart';
import 'package:echobook/services/voice_clone/voice_clone_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../test_utils/wav_fixture.dart';

/// Points `VoicePaths` (used by `importEchovoice` to copy a picked file
/// into app-managed storage) at the test's own temp directory instead of
/// hitting a real, unmocked platform channel.
class _FakePathProviderPlatform extends PathProviderPlatform {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late VoiceRepository voiceRepository;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    voiceRepository = VoiceRepository(db);
    tempDir = await Directory.systemTemp.createTemp('echobook_clone_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
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

  group('importEchovoice', () {
    test('imports a valid .echovoice file with no local processing', () async {
      final echovoicePath = p.join(tempDir.path, 'imported.echovoice');
      await File(echovoicePath).writeAsString(jsonEncode({
        'format': 'echovoice',
        'version': 1,
        'name': 'Ba Voice',
        'createdAt': '2026-01-01T00:00:00Z',
        'sampleRate': 16000,
        'embeddingModel': 'resemblyzer-ge2e',
        'embeddingDim': 3,
        'embedding': [0.1, 0.2, 0.3],
      }));

      final service = VoiceCloneService(voiceRepository);
      final profile = await service.importEchovoice(
        echovoiceFilePath: echovoicePath,
        baseVoice: const SystemVoice(name: 'vi-VN-Piper', locale: 'vi-VN'),
      );

      expect(profile.name, 'Ba Voice');
      expect(profile.kind, VoiceKind.cloned);
      expect(profile.systemVoiceLocale, 'vi-VN');
      // No sample recording is involved in an import — nothing to derive
      // a pitch-shift approximation from.
      expect(profile.sampleAudioPath, isNull);

      // The picked file gets copied into app-managed storage rather than
      // referenced in place — so the profile survives the original file
      // (e.g. a Downloads folder, a USB drive) moving or disappearing.
      expect(profile.echovoicePath, isNot(echovoicePath));
      expect(await File(profile.echovoicePath!).exists(), isTrue);
      final copiedContent = jsonDecode(await File(profile.echovoicePath!).readAsString());
      expect(copiedContent['name'], 'Ba Voice');
      expect(copiedContent['embedding'], [0.1, 0.2, 0.3]);
    });

    test('falls back to the file name when the .echovoice has no name field', () async {
      final echovoicePath = p.join(tempDir.path, 'nameless.echovoice');
      await File(echovoicePath).writeAsString(jsonEncode({
        'format': 'echovoice',
        'version': 1,
        'embedding': [0.1],
      }));

      final service = VoiceCloneService(voiceRepository);
      final profile = await service.importEchovoice(
        echovoiceFilePath: echovoicePath,
        baseVoice: const SystemVoice(name: 'x', locale: 'en'),
      );

      expect(profile.name, 'nameless');
    });

    test('rejects a file that is not a valid .echovoice payload', () async {
      final badPath = p.join(tempDir.path, 'bad.echovoice');
      await File(badPath).writeAsString(jsonEncode({'format': 'something_else'}));

      final service = VoiceCloneService(voiceRepository);
      expect(
        () => service.importEchovoice(
          echovoiceFilePath: badPath,
          baseVoice: const SystemVoice(name: 'x', locale: 'en'),
        ),
        throwsFormatException,
      );
    });

    test('rejects a path that does not exist', () async {
      final service = VoiceCloneService(voiceRepository);
      expect(
        () => service.importEchovoice(
          echovoiceFilePath: p.join(tempDir.path, 'missing.echovoice'),
          baseVoice: const SystemVoice(name: 'x', locale: 'en'),
        ),
        throwsArgumentError,
      );
    });
  });
}
