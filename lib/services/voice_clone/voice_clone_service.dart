import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/voice_repository.dart';
import '../tts/system_voice.dart';
import 'ai_server_client.dart';
import 'wav_pitch_estimator.dart';

/// Turns a recorded voice sample into a saved [VoiceProfile].
///
/// **Two cloning paths, side by side:**
/// - Everywhere, always: a lightweight offline pitch-shift approximation
///   (zero-crossing-rate estimate, see [WavPitchEstimator]) — keeps using
///   the device's real TTS engine, nudged toward the sample's pitch. Clearly
///   labeled Beta in the UI since it doesn't reproduce the user's actual
///   timbre.
/// - On Windows, when the local AI Server (`ai_server/`, see
///   [AiServerClient]/[AiServerManager]) is reachable: a real 256-dim
///   speaker embedding ("voice gene") extracted from the sample and saved
///   as a `.echovoice` file (`VoiceProfile.echovoicePath`). That embedding
///   isn't wired into playback yet — genuine embedding-conditioned
///   synthesis (e.g. Coqui XTTS) is a future upgrade — but capturing and
///   storing it now means that upgrade only needs a new synthesis backend,
///   not a new capture pipeline. `.echovoice` files are portable JSON, so a
///   profile cloned on Windows can be imported as-is on mobile (see
///   [importEchovoice]) with no local processing.
class VoiceCloneService {
  final VoiceRepository _voiceRepository;
  final AiServerClient _aiServerClient;
  static const _uuid = Uuid();

  VoiceCloneService(this._voiceRepository, {AiServerClient? aiServerClient})
      : _aiServerClient = aiServerClient ?? const AiServerClient();

  Future<VoiceProfileRow> createClonedProfile({
    required String name,
    required String sampleAudioPath,
    required SystemVoice baseVoice,
  }) async {
    final pitchShift = await WavPitchEstimator.estimatePitchShift(sampleAudioPath);
    final echovoicePath = await _tryCloneViaAiServer(name: name, sampleAudioPath: sampleAudioPath);

    final id = _uuid.v4();
    await _voiceRepository.upsert(VoiceProfilesCompanion.insert(
      id: id,
      name: name,
      kind: VoiceKind.cloned,
      systemVoiceId: Value(baseVoice.name),
      systemVoiceLocale: Value(baseVoice.locale),
      sampleAudioPath: Value(sampleAudioPath),
      echovoicePath: Value(echovoicePath),
      pitchShift: Value(pitchShift),
      pitch: Value(pitchShift),
      createdAt: DateTime.now(),
    ));

    final all = await _voiceRepository.getAll();
    return all.firstWhere((v) => v.id == id);
  }

  /// Attempts a real embedding-based clone via the local AI Server.
  /// Returns null (never throws) on any failure — unreachable server,
  /// non-Windows platform, or a bad sample — so the caller always still
  /// gets the pitch-shift-approximated profile above.
  Future<String?> _tryCloneViaAiServer({
    required String name,
    required String sampleAudioPath,
  }) async {
    if (!Platform.isWindows) return null;
    try {
      if (!await _aiServerClient.isHealthy()) return null;
      return await _aiServerClient.cloneVoice(name: name, sampleWavPath: sampleAudioPath);
    } catch (_) {
      return null;
    }
  }

  /// Imports a `.echovoice` file (produced by the AI Server, e.g. shared
  /// from a Windows machine) as a new cloned voice profile. No local
  /// processing is needed — this is the whole point of the format: mobile
  /// just imports it to use.
  Future<VoiceProfileRow> importEchovoice({
    required String echovoiceFilePath,
    required SystemVoice baseVoice,
  }) async {
    final file = File(echovoiceFilePath);
    if (!await file.exists()) {
      throw ArgumentError('$echovoiceFilePath does not exist.');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('$echovoiceFilePath is not valid JSON: $e');
    }
    if (data['format'] != 'echovoice' || data['embedding'] is! List) {
      throw const FormatException('Not a valid .echovoice file.');
    }

    final name = (data['name'] as String?)?.trim().isNotEmpty == true
        ? data['name'] as String
        : p.basenameWithoutExtension(echovoiceFilePath);

    final id = _uuid.v4();
    await _voiceRepository.upsert(VoiceProfilesCompanion.insert(
      id: id,
      name: name,
      kind: VoiceKind.cloned,
      systemVoiceId: Value(baseVoice.name),
      systemVoiceLocale: Value(baseVoice.locale),
      echovoicePath: Value(echovoiceFilePath),
      createdAt: DateTime.now(),
    ));

    final all = await _voiceRepository.getAll();
    return all.firstWhere((v) => v.id == id);
  }
}
