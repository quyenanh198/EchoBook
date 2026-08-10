import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/db/app_database.dart';
import '../../../services/export/export_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(exportRepositoryProvider));
});

final exportJobsProvider = StreamProvider<List<ExportJobRow>>((ref) {
  return ref.watch(exportRepositoryProvider).watchAll();
});

/// Book currently selected in the Export tab (independent of the Reader
/// tab's open book, though the screen defaults to it).
final exportSelectedBookIdProvider = StateProvider<String?>((ref) => null);
