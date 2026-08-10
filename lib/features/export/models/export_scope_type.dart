enum ExportScopeType { currentChapter, selectedChapters, entireBook, customRange }

extension ExportScopeTypeX on ExportScopeType {
  String get label => switch (this) {
        ExportScopeType.currentChapter => 'Current chapter',
        ExportScopeType.selectedChapters => 'Selected chapters',
        ExportScopeType.entireBook => 'Entire book',
        ExportScopeType.customRange => 'Custom range',
      };

  /// The value persisted in ExportJobs.scopeType.
  String get storageKey => switch (this) {
        ExportScopeType.currentChapter => 'current',
        ExportScopeType.selectedChapters => 'selected',
        ExportScopeType.entireBook => 'book',
        ExportScopeType.customRange => 'range',
      };
}
