import 'dart:io';

import 'package:path/path.dart' as p;

import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/export_repository.dart';
import '../parsing/parsed_book.dart';
import '../tts/tts_file_synthesizer.dart';
import '../tts/tts_file_synthesizer_factory.dart';
import 'format_converter.dart';
import 'wav_tools.dart';

class ExportService {
  final ExportRepository _exportRepository;

  /// Overrides the platform-default synthesizer — used by tests to inject a
  /// fake that writes fixture WAV bytes instead of shelling out to a real
  /// native TTS engine.
  final TtsFileSynthesizer? synthesizerOverride;

  ExportService(this._exportRepository, {this.synthesizerOverride});

  Future<void> run({
    required ExportJobRow job,
    required List<ParsedChapter> chapters,
    required List<int> chapterIndices,
    required VoiceProfileRow voice,
    required String bookTitle,
    required String outputDir,
  }) async {
    Directory? tempDir;
    try {
      await _exportRepository.updateProgress(job.id, 0, status: ExportStatus.running);
      final synthesizer = synthesizerOverride ?? TtsFileSynthesizerFactory.create();

      tempDir = await Directory(p.join(outputDir, '.tmp_${job.id}')).create(recursive: true);
      final wavParts = <String>[];

      for (var i = 0; i < chapterIndices.length; i++) {
        final chapter = chapters[chapterIndices[i]];
        final partPath = p.join(tempDir.path, 'part_$i.wav');
        await synthesizer.synthesizeToFile(
          text: chapter.plainText,
          outputWavPath: partPath,
          voiceName: voice.systemVoiceId,
          voiceLocale: voice.systemVoiceLocale,
          speed: job.speed,
          pitch: voice.pitch,
        );
        wavParts.add(partPath);
        await _exportRepository.updateProgress(job.id, (i + 1) / chapterIndices.length * 0.85);
      }

      final mergedWav = p.join(tempDir.path, 'merged.wav');
      await WavTools.concatenate(wavParts, mergedWav);
      await _exportRepository.updateProgress(job.id, 0.92);

      final format = ExportFormat.values.byName(job.format);
      final safeTitle = _sanitizeFileName(bookTitle);
      final idSuffix = job.id.substring(0, job.id.length < 8 ? job.id.length : 8);
      final finalPath = p.join(outputDir, '$safeTitle-$idSuffix.${format.extension}');
      final actualPath = await FormatConverter.convert(
        wavPath: mergedWav,
        outputPath: finalPath,
        format: format,
      );

      final bytes = await File(actualPath).length();
      await _exportRepository.complete(job.id, actualPath, bytes);
    } catch (e) {
      await _exportRepository.fail(job.id, e.toString());
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  String _sanitizeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();
    return cleaned.isEmpty ? 'export' : (cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned);
  }
}
