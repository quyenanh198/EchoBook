import 'package:drift/drift.dart';

import '../db/app_database.dart';

class VoiceRepository {
  final AppDatabase _db;

  VoiceRepository(this._db);

  Stream<List<VoiceProfileRow>> watchAll() {
    return (_db.select(_db.voiceProfiles)
          ..orderBy([(v) => OrderingTerm.asc(v.createdAt)]))
        .watch();
  }

  Future<List<VoiceProfileRow>> getAll() => _db.select(_db.voiceProfiles).get();

  Future<VoiceProfileRow?> getDefault() {
    return (_db.select(_db.voiceProfiles)..where((v) => v.isDefault.equals(true)))
        .getSingleOrNull();
  }

  Future<void> upsert(VoiceProfilesCompanion voice) {
    return _db.into(_db.voiceProfiles).insertOnConflictUpdate(voice);
  }

  Future<void> setDefault(String id) async {
    await _db.transaction(() async {
      await _db.update(_db.voiceProfiles).write(const VoiceProfilesCompanion(isDefault: Value(false)));
      await (_db.update(_db.voiceProfiles)..where((v) => v.id.equals(id)))
          .write(const VoiceProfilesCompanion(isDefault: Value(true)));
    });
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.voiceProfiles)..where((v) => v.id.equals(id))).go();
  }
}
