import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

class ExportRepository {
  final AppDatabase _db;

  ExportRepository(this._db);

  Stream<List<ExportJobRow>> watchAll() {
    return (_db.select(_db.exportJobs)
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch();
  }

  Future<void> upsert(ExportJobsCompanion job) {
    return _db.into(_db.exportJobs).insertOnConflictUpdate(job);
  }

  Future<void> updateProgress(String id, double progress, {String? status}) {
    return (_db.update(_db.exportJobs)..where((e) => e.id.equals(id))).write(
      ExportJobsCompanion(
        progress: Value(progress),
        status: status != null ? Value(status) : const Value.absent(),
      ),
    );
  }

  Future<void> complete(String id, String outputPath, int bytes) {
    return (_db.update(_db.exportJobs)..where((e) => e.id.equals(id))).write(
      ExportJobsCompanion(
        status: const Value(ExportStatus.completed),
        progress: const Value(1.0),
        outputPath: Value(outputPath),
        estimatedBytes: Value(bytes),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> fail(String id, String message) {
    return (_db.update(_db.exportJobs)..where((e) => e.id.equals(id))).write(
      ExportJobsCompanion(
        status: const Value(ExportStatus.failed),
        errorMessage: Value(message),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.exportJobs)..where((e) => e.id.equals(id))).go();
  }
}
