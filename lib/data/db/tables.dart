import 'package:drift/drift.dart';

/// Supported source ebook formats.
class BookFormat {
  static const epub = 'epub';
  static const pdf = 'pdf';
  static const txt = 'txt';
  static const mobi = 'mobi';
  static const azw3 = 'azw3';
}

@DataClassName('BookRow')
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant('Unknown Author'))();
  TextColumn get format => text()();
  TextColumn get filePath => text()();
  TextColumn get coverPath => text().nullable()();
  IntColumn get chapterCount => integer().withDefault(const Constant(0))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  TextColumn get contentCachePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReadingProgressRow')
class ReadingProgressTable extends Table {
  TextColumn get bookId => text()();
  IntColumn get chapterIndex => integer().withDefault(const Constant(0))();
  RealColumn get chapterFraction => real().withDefault(const Constant(0))();
  RealColumn get overallFraction => real().withDefault(const Constant(0))();
  IntColumn get characterOffset => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bookId};
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  IntColumn get chapterIndex => integer()();
  IntColumn get characterOffset => integer()();
  TextColumn get excerpt => text()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Origin of a voice profile.
class VoiceKind {
  static const system = 'system';
  static const cloned = 'cloned';
}

@DataClassName('VoiceProfileRow')
class VoiceProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get systemVoiceId => text().nullable()();
  TextColumn get systemVoiceLocale => text().nullable()();
  TextColumn get sampleAudioPath => text().nullable()();
  /// Path to a `.echovoice` file (speaker embedding produced by the local
  /// AI Server, or imported from one) — see `ai_server/` and
  /// `VoiceCloneService`. Null for profiles that only have the offline
  /// pitch-shift approximation.
  TextColumn get echovoicePath => text().nullable()();
  RealColumn get pitchShift => real().withDefault(const Constant(0))();
  RealColumn get speed => real().withDefault(const Constant(1.0))();
  RealColumn get pitch => real().withDefault(const Constant(1.0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lifecycle status of an export job.
class ExportStatus {
  static const queued = 'queued';
  static const running = 'running';
  static const completed = 'completed';
  static const failed = 'failed';
  static const canceled = 'canceled';
}

@DataClassName('ExportJobRow')
class ExportJobs extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  TextColumn get voiceProfileId => text()();
  TextColumn get scopeType => text()(); // current | selected | book | range
  TextColumn get scopeJson => text()(); // json-encoded chapter indices / range
  RealColumn get speed => real().withDefault(const Constant(1.0))();
  TextColumn get format => text()(); // mp3128 | mp3192 | mp3320 | m4a | wav
  TextColumn get status => text().withDefault(const Constant('queued'))();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get outputPath => text().nullable()();
  IntColumn get estimatedBytes => integer().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
