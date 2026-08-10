import 'dart:io';

import 'package:drift/native.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
import 'package:echobook/data/repositories/export_repository.dart';
import 'package:echobook/services/export/export_service.dart';
import 'package:echobook/services/parsing/parsed_book.dart';
import 'package:echobook/services/tts/tts_file_synthesizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../test_utils/wav_fixture.dart';

/// Fake synthesizer that writes a short fixture WAV instead of invoking a
/// real (platform-specific) TTS engine, so export orchestration — progress
/// updates, chapter ordering, concatenation, completion — can be tested
/// deterministically on any machine.
class FakeTtsFileSynthesizer implements TtsFileSynthesizer {
  final List<String> synthesizedTexts = [];
  bool shouldFail = false;

  @override
  bool get isSupported => true;

  @override
  Future<void> synthesizeToFile({
    required String text,
    required String outputWavPath,
    String? voiceName,
    String? voiceLocale,
    required double speed,
    required double pitch,
  }) async {
    if (shouldFail) throw Exception('fake synthesis failure');
    synthesizedTexts.add(text);
    await File(outputWavPath).writeAsBytes(
      buildTestWav(List.filled(800, 50), sampleRate: 8000),
    );
  }
}

void main() {
  late AppDatabase db;
  late ExportRepository exportRepository;
  late Directory tempDir;
  late FakeTtsFileSynthesizer fakeSynthesizer;

  final chapters = const [
    ParsedChapter(title: 'Ch1', plainText: 'First chapter text.'),
    ParsedChapter(title: 'Ch2', plainText: 'Second chapter text.'),
    ParsedChapter(title: 'Ch3', plainText: 'Third chapter text.'),
  ];

  final voice = VoiceProfileRow(
    id: 'voice-1',
    name: 'Test Voice',
    kind: VoiceKind.system,
    systemVoiceId: 'Microsoft David',
    systemVoiceLocale: 'en-US',
    sampleAudioPath: null,
    pitchShift: 0,
    speed: 1.0,
    pitch: 1.0,
    isDefault: true,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    exportRepository = ExportRepository(db);
    tempDir = await Directory.systemTemp.createTemp('echobook_export_test_');
    fakeSynthesizer = FakeTtsFileSynthesizer();
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  ExportJobRow jobFor(String id, {String format = 'wav'}) => ExportJobRow(
        id: id,
        bookId: 'book-1',
        voiceProfileId: voice.id,
        scopeType: 'book',
        scopeJson: '[0,1,2]',
        speed: 1.0,
        format: format,
        status: ExportStatus.queued,
        progress: 0,
        outputPath: null,
        estimatedBytes: null,
        errorMessage: null,
        createdAt: DateTime(2026, 1, 1),
        completedAt: null,
      );

  test('synthesizes every chapter in scope, in order, and completes the job', () async {
    final job = jobFor('job-1');
    await exportRepository.upsert(job.toCompanion(true));

    final service = ExportService(exportRepository, synthesizerOverride: fakeSynthesizer);
    await service.run(
      job: job,
      chapters: chapters,
      chapterIndices: [0, 1, 2],
      voice: voice,
      bookTitle: 'My Book',
      outputDir: tempDir.path,
    );

    expect(fakeSynthesizer.synthesizedTexts, [
      'First chapter text.',
      'Second chapter text.',
      'Third chapter text.',
    ]);

    final completed = (await exportRepository.watchAll().first).firstWhere((j) => j.id == 'job-1');
    expect(completed.status, ExportStatus.completed);
    expect(completed.progress, 1.0);
    expect(completed.outputPath, isNotNull);
    expect(await File(completed.outputPath!).exists(), isTrue);
  });

  test('only synthesizes chapters within the requested scope', () async {
    final job = jobFor('job-2');
    await exportRepository.upsert(job.toCompanion(true));

    final service = ExportService(exportRepository, synthesizerOverride: fakeSynthesizer);
    await service.run(
      job: job,
      chapters: chapters,
      chapterIndices: [1],
      voice: voice,
      bookTitle: 'My Book',
      outputDir: tempDir.path,
    );

    expect(fakeSynthesizer.synthesizedTexts, ['Second chapter text.']);
  });

  test('marks the job failed and records the error when synthesis throws', () async {
    fakeSynthesizer.shouldFail = true;
    final job = jobFor('job-3');
    await exportRepository.upsert(job.toCompanion(true));

    final service = ExportService(exportRepository, synthesizerOverride: fakeSynthesizer);
    await service.run(
      job: job,
      chapters: chapters,
      chapterIndices: [0],
      voice: voice,
      bookTitle: 'My Book',
      outputDir: tempDir.path,
    );

    final failed = (await exportRepository.watchAll().first).firstWhere((j) => j.id == 'job-3');
    expect(failed.status, ExportStatus.failed);
    expect(failed.errorMessage, contains('fake synthesis failure'));
  });

  test('cleans up its temp working directory after a run', () async {
    final job = jobFor('job-4');
    await exportRepository.upsert(job.toCompanion(true));

    final service = ExportService(exportRepository, synthesizerOverride: fakeSynthesizer);
    await service.run(
      job: job,
      chapters: chapters,
      chapterIndices: [0, 1],
      voice: voice,
      bookTitle: 'Cleanup Test',
      outputDir: tempDir.path,
    );

    final leftoverTempDirs = tempDir
        .listSync()
        .whereType<Directory>()
        .where((d) => p.basename(d.path).startsWith('.tmp_'));
    expect(leftoverTempDirs, isEmpty);
  });

  test('output filename is sanitized from the book title', () async {
    final job = jobFor('job-5');
    await exportRepository.upsert(job.toCompanion(true));

    final service = ExportService(exportRepository, synthesizerOverride: fakeSynthesizer);
    await service.run(
      job: job,
      chapters: chapters,
      chapterIndices: [0],
      voice: voice,
      bookTitle: 'Weird: Title / With * Bad? Chars',
      outputDir: tempDir.path,
    );

    final completed = (await exportRepository.watchAll().first).firstWhere((j) => j.id == 'job-5');
    final fileName = p.basename(completed.outputPath!);
    expect(fileName, isNot(contains(RegExp(r'[\\/:*?"<>|]'))));
  });
}
