import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/tables.dart';
import '../../../services/tts/system_voice.dart';
import '../../../services/tts/voice_engine_factory.dart';
import '../../../services/voice_clone/voice_clone_service.dart';

final systemVoicesProvider = FutureProvider<List<SystemVoice>>((ref) async {
  final engine = VoiceEngineFactory.create();
  try {
    return await engine.getVoices();
  } finally {
    engine.dispose();
  }
});

final voiceProfilesProvider = StreamProvider<List<VoiceProfileRow>>((ref) {
  return ref.watch(voiceRepositoryProvider).watchAll();
});

final voiceCloneServiceProvider = Provider<VoiceCloneService>((ref) {
  return VoiceCloneService(ref.watch(voiceRepositoryProvider));
});

/// Ensures the library is never left without a usable default voice: the
/// first time the Voices screen loads with an empty profile list, this
/// creates one from the platform's first available system voice.
final defaultVoiceBootstrapProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(voiceRepositoryProvider);
  final existing = await repo.getAll();
  if (existing.isNotEmpty) return;

  final voices = await ref.watch(systemVoicesProvider.future);
  if (voices.isEmpty) return;

  // Prefer a voice matching the device's own language (e.g. Vietnamese on a
  // vi_VN system) before falling back to English, then to whatever's first.
  final systemLanguage = Platform.localeName.split(RegExp('[_.-]')).first.toLowerCase();
  final preferred = voices.firstWhere(
    (v) => v.locale.toLowerCase().startsWith(systemLanguage),
    orElse: () => voices.firstWhere(
      (v) => v.locale.toLowerCase().startsWith('en'),
      orElse: () => voices.first,
    ),
  );

  await repo.upsert(VoiceProfilesCompanion.insert(
    id: const Uuid().v4(),
    name: preferred.name,
    kind: VoiceKind.system,
    systemVoiceId: Value(preferred.name),
    systemVoiceLocale: Value(preferred.locale),
    isDefault: const Value(true),
    createdAt: DateTime.now(),
  ));
});
