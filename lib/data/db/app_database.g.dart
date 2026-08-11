// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown Author'),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterCountMeta = const VerificationMeta(
    'chapterCount',
  );
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
    'chapter_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentCachePathMeta = const VerificationMeta(
    'contentCachePath',
  );
  @override
  late final GeneratedColumn<String> contentCachePath = GeneratedColumn<String>(
    'content_cache_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    format,
    filePath,
    coverPath,
    chapterCount,
    wordCount,
    importedAt,
    lastOpenedAt,
    contentCachePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
        _chapterCountMeta,
        chapterCount.isAcceptableOrUnknown(
          data['chapter_count']!,
          _chapterCountMeta,
        ),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    if (data.containsKey('content_cache_path')) {
      context.handle(
        _contentCachePathMeta,
        contentCachePath.isAcceptableOrUnknown(
          data['content_cache_path']!,
          _contentCachePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      chapterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_count'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
      contentCachePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_cache_path'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final String id;
  final String title;
  final String author;
  final String format;
  final String filePath;
  final String? coverPath;
  final int chapterCount;
  final int wordCount;
  final DateTime importedAt;
  final DateTime? lastOpenedAt;
  final String? contentCachePath;
  const BookRow({
    required this.id,
    required this.title,
    required this.author,
    required this.format,
    required this.filePath,
    this.coverPath,
    required this.chapterCount,
    required this.wordCount,
    required this.importedAt,
    this.lastOpenedAt,
    this.contentCachePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['format'] = Variable<String>(format);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['chapter_count'] = Variable<int>(chapterCount);
    map['word_count'] = Variable<int>(wordCount);
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    if (!nullToAbsent || contentCachePath != null) {
      map['content_cache_path'] = Variable<String>(contentCachePath);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      format: Value(format),
      filePath: Value(filePath),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      chapterCount: Value(chapterCount),
      wordCount: Value(wordCount),
      importedAt: Value(importedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      contentCachePath: contentCachePath == null && nullToAbsent
          ? const Value.absent()
          : Value(contentCachePath),
    );
  }

  factory BookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      format: serializer.fromJson<String>(json['format']),
      filePath: serializer.fromJson<String>(json['filePath']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      chapterCount: serializer.fromJson<int>(json['chapterCount']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      contentCachePath: serializer.fromJson<String?>(json['contentCachePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'format': serializer.toJson<String>(format),
      'filePath': serializer.toJson<String>(filePath),
      'coverPath': serializer.toJson<String?>(coverPath),
      'chapterCount': serializer.toJson<int>(chapterCount),
      'wordCount': serializer.toJson<int>(wordCount),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'contentCachePath': serializer.toJson<String?>(contentCachePath),
    };
  }

  BookRow copyWith({
    String? id,
    String? title,
    String? author,
    String? format,
    String? filePath,
    Value<String?> coverPath = const Value.absent(),
    int? chapterCount,
    int? wordCount,
    DateTime? importedAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
    Value<String?> contentCachePath = const Value.absent(),
  }) => BookRow(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    format: format ?? this.format,
    filePath: filePath ?? this.filePath,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    chapterCount: chapterCount ?? this.chapterCount,
    wordCount: wordCount ?? this.wordCount,
    importedAt: importedAt ?? this.importedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
    contentCachePath: contentCachePath.present
        ? contentCachePath.value
        : this.contentCachePath,
  );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      format: data.format.present ? data.format.value : this.format,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      contentCachePath: data.contentCachePath.present
          ? data.contentCachePath.value
          : this.contentCachePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('format: $format, ')
          ..write('filePath: $filePath, ')
          ..write('coverPath: $coverPath, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('wordCount: $wordCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('contentCachePath: $contentCachePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    format,
    filePath,
    coverPath,
    chapterCount,
    wordCount,
    importedAt,
    lastOpenedAt,
    contentCachePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.format == this.format &&
          other.filePath == this.filePath &&
          other.coverPath == this.coverPath &&
          other.chapterCount == this.chapterCount &&
          other.wordCount == this.wordCount &&
          other.importedAt == this.importedAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.contentCachePath == this.contentCachePath);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> format;
  final Value<String> filePath;
  final Value<String?> coverPath;
  final Value<int> chapterCount;
  final Value<int> wordCount;
  final Value<DateTime> importedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<String?> contentCachePath;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.format = const Value.absent(),
    this.filePath = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.contentCachePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    required String format,
    required String filePath,
    this.coverPath = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.wordCount = const Value.absent(),
    required DateTime importedAt,
    this.lastOpenedAt = const Value.absent(),
    this.contentCachePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       format = Value(format),
       filePath = Value(filePath),
       importedAt = Value(importedAt);
  static Insertable<BookRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? format,
    Expression<String>? filePath,
    Expression<String>? coverPath,
    Expression<int>? chapterCount,
    Expression<int>? wordCount,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<String>? contentCachePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (format != null) 'format': format,
      if (filePath != null) 'file_path': filePath,
      if (coverPath != null) 'cover_path': coverPath,
      if (chapterCount != null) 'chapter_count': chapterCount,
      if (wordCount != null) 'word_count': wordCount,
      if (importedAt != null) 'imported_at': importedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (contentCachePath != null) 'content_cache_path': contentCachePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? author,
    Value<String>? format,
    Value<String>? filePath,
    Value<String?>? coverPath,
    Value<int>? chapterCount,
    Value<int>? wordCount,
    Value<DateTime>? importedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<String?>? contentCachePath,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      filePath: filePath ?? this.filePath,
      coverPath: coverPath ?? this.coverPath,
      chapterCount: chapterCount ?? this.chapterCount,
      wordCount: wordCount ?? this.wordCount,
      importedAt: importedAt ?? this.importedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      contentCachePath: contentCachePath ?? this.contentCachePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (contentCachePath.present) {
      map['content_cache_path'] = Variable<String>(contentCachePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('format: $format, ')
          ..write('filePath: $filePath, ')
          ..write('coverPath: $coverPath, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('wordCount: $wordCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('contentCachePath: $contentCachePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTableTable extends ReadingProgressTable
    with TableInfo<$ReadingProgressTableTable, ReadingProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chapterFractionMeta = const VerificationMeta(
    'chapterFraction',
  );
  @override
  late final GeneratedColumn<double> chapterFraction = GeneratedColumn<double>(
    'chapter_fraction',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _overallFractionMeta = const VerificationMeta(
    'overallFraction',
  );
  @override
  late final GeneratedColumn<double> overallFraction = GeneratedColumn<double>(
    'overall_fraction',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _characterOffsetMeta = const VerificationMeta(
    'characterOffset',
  );
  @override
  late final GeneratedColumn<int> characterOffset = GeneratedColumn<int>(
    'character_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    chapterIndex,
    chapterFraction,
    overallFraction,
    characterOffset,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('chapter_fraction')) {
      context.handle(
        _chapterFractionMeta,
        chapterFraction.isAcceptableOrUnknown(
          data['chapter_fraction']!,
          _chapterFractionMeta,
        ),
      );
    }
    if (data.containsKey('overall_fraction')) {
      context.handle(
        _overallFractionMeta,
        overallFraction.isAcceptableOrUnknown(
          data['overall_fraction']!,
          _overallFractionMeta,
        ),
      );
    }
    if (data.containsKey('character_offset')) {
      context.handle(
        _characterOffsetMeta,
        characterOffset.isAcceptableOrUnknown(
          data['character_offset']!,
          _characterOffsetMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ReadingProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      chapterFraction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chapter_fraction'],
      )!,
      overallFraction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_fraction'],
      )!,
      characterOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_offset'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReadingProgressTableTable createAlias(String alias) {
    return $ReadingProgressTableTable(attachedDatabase, alias);
  }
}

class ReadingProgressRow extends DataClass
    implements Insertable<ReadingProgressRow> {
  final String bookId;
  final int chapterIndex;
  final double chapterFraction;
  final double overallFraction;
  final int characterOffset;
  final DateTime updatedAt;
  const ReadingProgressRow({
    required this.bookId,
    required this.chapterIndex,
    required this.chapterFraction,
    required this.overallFraction,
    required this.characterOffset,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['chapter_fraction'] = Variable<double>(chapterFraction);
    map['overall_fraction'] = Variable<double>(overallFraction);
    map['character_offset'] = Variable<int>(characterOffset);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressTableCompanion(
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      chapterFraction: Value(chapterFraction),
      overallFraction: Value(overallFraction),
      characterOffset: Value(characterOffset),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      chapterFraction: serializer.fromJson<double>(json['chapterFraction']),
      overallFraction: serializer.fromJson<double>(json['overallFraction']),
      characterOffset: serializer.fromJson<int>(json['characterOffset']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'chapterFraction': serializer.toJson<double>(chapterFraction),
      'overallFraction': serializer.toJson<double>(overallFraction),
      'characterOffset': serializer.toJson<int>(characterOffset),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressRow copyWith({
    String? bookId,
    int? chapterIndex,
    double? chapterFraction,
    double? overallFraction,
    int? characterOffset,
    DateTime? updatedAt,
  }) => ReadingProgressRow(
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    chapterFraction: chapterFraction ?? this.chapterFraction,
    overallFraction: overallFraction ?? this.overallFraction,
    characterOffset: characterOffset ?? this.characterOffset,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingProgressRow copyWithCompanion(ReadingProgressTableCompanion data) {
    return ReadingProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      chapterFraction: data.chapterFraction.present
          ? data.chapterFraction.value
          : this.chapterFraction,
      overallFraction: data.overallFraction.present
          ? data.overallFraction.value
          : this.overallFraction,
      characterOffset: data.characterOffset.present
          ? data.characterOffset.value
          : this.characterOffset,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterFraction: $chapterFraction, ')
          ..write('overallFraction: $overallFraction, ')
          ..write('characterOffset: $characterOffset, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookId,
    chapterIndex,
    chapterFraction,
    overallFraction,
    characterOffset,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressRow &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.chapterFraction == this.chapterFraction &&
          other.overallFraction == this.overallFraction &&
          other.characterOffset == this.characterOffset &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressTableCompanion
    extends UpdateCompanion<ReadingProgressRow> {
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<double> chapterFraction;
  final Value<double> overallFraction;
  final Value<int> characterOffset;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingProgressTableCompanion({
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.chapterFraction = const Value.absent(),
    this.overallFraction = const Value.absent(),
    this.characterOffset = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressTableCompanion.insert({
    required String bookId,
    this.chapterIndex = const Value.absent(),
    this.chapterFraction = const Value.absent(),
    this.overallFraction = const Value.absent(),
    this.characterOffset = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       updatedAt = Value(updatedAt);
  static Insertable<ReadingProgressRow> custom({
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<double>? chapterFraction,
    Expression<double>? overallFraction,
    Expression<int>? characterOffset,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (chapterFraction != null) 'chapter_fraction': chapterFraction,
      if (overallFraction != null) 'overall_fraction': overallFraction,
      if (characterOffset != null) 'character_offset': characterOffset,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressTableCompanion copyWith({
    Value<String>? bookId,
    Value<int>? chapterIndex,
    Value<double>? chapterFraction,
    Value<double>? overallFraction,
    Value<int>? characterOffset,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReadingProgressTableCompanion(
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterFraction: chapterFraction ?? this.chapterFraction,
      overallFraction: overallFraction ?? this.overallFraction,
      characterOffset: characterOffset ?? this.characterOffset,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (chapterFraction.present) {
      map['chapter_fraction'] = Variable<double>(chapterFraction.value);
    }
    if (overallFraction.present) {
      map['overall_fraction'] = Variable<double>(overallFraction.value);
    }
    if (characterOffset.present) {
      map['character_offset'] = Variable<int>(characterOffset.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressTableCompanion(')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterFraction: $chapterFraction, ')
          ..write('overallFraction: $overallFraction, ')
          ..write('characterOffset: $characterOffset, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterOffsetMeta = const VerificationMeta(
    'characterOffset',
  );
  @override
  late final GeneratedColumn<int> characterOffset = GeneratedColumn<int>(
    'character_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excerptMeta = const VerificationMeta(
    'excerpt',
  );
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
    'excerpt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterIndex,
    characterOffset,
    excerpt,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('character_offset')) {
      context.handle(
        _characterOffsetMeta,
        characterOffset.isAcceptableOrUnknown(
          data['character_offset']!,
          _characterOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterOffsetMeta);
    }
    if (data.containsKey('excerpt')) {
      context.handle(
        _excerptMeta,
        excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta),
      );
    } else if (isInserting) {
      context.missing(_excerptMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      characterOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_offset'],
      )!,
      excerpt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}excerpt'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String id;
  final String bookId;
  final int chapterIndex;
  final int characterOffset;
  final String excerpt;
  final String? label;
  final DateTime createdAt;
  const BookmarkRow({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.characterOffset,
    required this.excerpt,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['character_offset'] = Variable<int>(characterOffset);
    map['excerpt'] = Variable<String>(excerpt);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      characterOffset: Value(characterOffset),
      excerpt: Value(excerpt),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      characterOffset: serializer.fromJson<int>(json['characterOffset']),
      excerpt: serializer.fromJson<String>(json['excerpt']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'characterOffset': serializer.toJson<int>(characterOffset),
      'excerpt': serializer.toJson<String>(excerpt),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkRow copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    int? characterOffset,
    String? excerpt,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => BookmarkRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    characterOffset: characterOffset ?? this.characterOffset,
    excerpt: excerpt ?? this.excerpt,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      characterOffset: data.characterOffset.present
          ? data.characterOffset.value
          : this.characterOffset,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('characterOffset: $characterOffset, ')
          ..write('excerpt: $excerpt, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterIndex,
    characterOffset,
    excerpt,
    label,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.characterOffset == this.characterOffset &&
          other.excerpt == this.excerpt &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<int> characterOffset;
  final Value<String> excerpt;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.characterOffset = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required String bookId,
    required int chapterIndex,
    required int characterOffset,
    required String excerpt,
    this.label = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       characterOffset = Value(characterOffset),
       excerpt = Value(excerpt),
       createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<int>? characterOffset,
    Expression<String>? excerpt,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (characterOffset != null) 'character_offset': characterOffset,
      if (excerpt != null) 'excerpt': excerpt,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? chapterIndex,
    Value<int>? characterOffset,
    Value<String>? excerpt,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      characterOffset: characterOffset ?? this.characterOffset,
      excerpt: excerpt ?? this.excerpt,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (characterOffset.present) {
      map['character_offset'] = Variable<int>(characterOffset.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('characterOffset: $characterOffset, ')
          ..write('excerpt: $excerpt, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoiceProfilesTable extends VoiceProfiles
    with TableInfo<$VoiceProfilesTable, VoiceProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemVoiceIdMeta = const VerificationMeta(
    'systemVoiceId',
  );
  @override
  late final GeneratedColumn<String> systemVoiceId = GeneratedColumn<String>(
    'system_voice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemVoiceLocaleMeta = const VerificationMeta(
    'systemVoiceLocale',
  );
  @override
  late final GeneratedColumn<String> systemVoiceLocale =
      GeneratedColumn<String>(
        'system_voice_locale',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sampleAudioPathMeta = const VerificationMeta(
    'sampleAudioPath',
  );
  @override
  late final GeneratedColumn<String> sampleAudioPath = GeneratedColumn<String>(
    'sample_audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _echovoicePathMeta = const VerificationMeta(
    'echovoicePath',
  );
  @override
  late final GeneratedColumn<String> echovoicePath = GeneratedColumn<String>(
    'echovoice_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pitchShiftMeta = const VerificationMeta(
    'pitchShift',
  );
  @override
  late final GeneratedColumn<double> pitchShift = GeneratedColumn<double>(
    'pitch_shift',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _pitchMeta = const VerificationMeta('pitch');
  @override
  late final GeneratedColumn<double> pitch = GeneratedColumn<double>(
    'pitch',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    systemVoiceId,
    systemVoiceLocale,
    sampleAudioPath,
    echovoicePath,
    pitchShift,
    speed,
    pitch,
    isDefault,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('system_voice_id')) {
      context.handle(
        _systemVoiceIdMeta,
        systemVoiceId.isAcceptableOrUnknown(
          data['system_voice_id']!,
          _systemVoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('system_voice_locale')) {
      context.handle(
        _systemVoiceLocaleMeta,
        systemVoiceLocale.isAcceptableOrUnknown(
          data['system_voice_locale']!,
          _systemVoiceLocaleMeta,
        ),
      );
    }
    if (data.containsKey('sample_audio_path')) {
      context.handle(
        _sampleAudioPathMeta,
        sampleAudioPath.isAcceptableOrUnknown(
          data['sample_audio_path']!,
          _sampleAudioPathMeta,
        ),
      );
    }
    if (data.containsKey('echovoice_path')) {
      context.handle(
        _echovoicePathMeta,
        echovoicePath.isAcceptableOrUnknown(
          data['echovoice_path']!,
          _echovoicePathMeta,
        ),
      );
    }
    if (data.containsKey('pitch_shift')) {
      context.handle(
        _pitchShiftMeta,
        pitchShift.isAcceptableOrUnknown(data['pitch_shift']!, _pitchShiftMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('pitch')) {
      context.handle(
        _pitchMeta,
        pitch.isAcceptableOrUnknown(data['pitch']!, _pitchMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      systemVoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_voice_id'],
      ),
      systemVoiceLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_voice_locale'],
      ),
      sampleAudioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_audio_path'],
      ),
      echovoicePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}echovoice_path'],
      ),
      pitchShift: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pitch_shift'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      pitch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pitch'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VoiceProfilesTable createAlias(String alias) {
    return $VoiceProfilesTable(attachedDatabase, alias);
  }
}

class VoiceProfileRow extends DataClass implements Insertable<VoiceProfileRow> {
  final String id;
  final String name;
  final String kind;
  final String? systemVoiceId;
  final String? systemVoiceLocale;
  final String? sampleAudioPath;

  /// Path to a `.echovoice` file (speaker embedding produced by the local
  /// AI Server, or imported from one) — see `ai_server/` and
  /// `VoiceCloneService`. Null for profiles that only have the offline
  /// pitch-shift approximation.
  final String? echovoicePath;
  final double pitchShift;
  final double speed;
  final double pitch;
  final bool isDefault;
  final DateTime createdAt;
  const VoiceProfileRow({
    required this.id,
    required this.name,
    required this.kind,
    this.systemVoiceId,
    this.systemVoiceLocale,
    this.sampleAudioPath,
    this.echovoicePath,
    required this.pitchShift,
    required this.speed,
    required this.pitch,
    required this.isDefault,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || systemVoiceId != null) {
      map['system_voice_id'] = Variable<String>(systemVoiceId);
    }
    if (!nullToAbsent || systemVoiceLocale != null) {
      map['system_voice_locale'] = Variable<String>(systemVoiceLocale);
    }
    if (!nullToAbsent || sampleAudioPath != null) {
      map['sample_audio_path'] = Variable<String>(sampleAudioPath);
    }
    if (!nullToAbsent || echovoicePath != null) {
      map['echovoice_path'] = Variable<String>(echovoicePath);
    }
    map['pitch_shift'] = Variable<double>(pitchShift);
    map['speed'] = Variable<double>(speed);
    map['pitch'] = Variable<double>(pitch);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VoiceProfilesCompanion toCompanion(bool nullToAbsent) {
    return VoiceProfilesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      systemVoiceId: systemVoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemVoiceId),
      systemVoiceLocale: systemVoiceLocale == null && nullToAbsent
          ? const Value.absent()
          : Value(systemVoiceLocale),
      sampleAudioPath: sampleAudioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleAudioPath),
      echovoicePath: echovoicePath == null && nullToAbsent
          ? const Value.absent()
          : Value(echovoicePath),
      pitchShift: Value(pitchShift),
      speed: Value(speed),
      pitch: Value(pitch),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory VoiceProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      systemVoiceId: serializer.fromJson<String?>(json['systemVoiceId']),
      systemVoiceLocale: serializer.fromJson<String?>(
        json['systemVoiceLocale'],
      ),
      sampleAudioPath: serializer.fromJson<String?>(json['sampleAudioPath']),
      echovoicePath: serializer.fromJson<String?>(json['echovoicePath']),
      pitchShift: serializer.fromJson<double>(json['pitchShift']),
      speed: serializer.fromJson<double>(json['speed']),
      pitch: serializer.fromJson<double>(json['pitch']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'systemVoiceId': serializer.toJson<String?>(systemVoiceId),
      'systemVoiceLocale': serializer.toJson<String?>(systemVoiceLocale),
      'sampleAudioPath': serializer.toJson<String?>(sampleAudioPath),
      'echovoicePath': serializer.toJson<String?>(echovoicePath),
      'pitchShift': serializer.toJson<double>(pitchShift),
      'speed': serializer.toJson<double>(speed),
      'pitch': serializer.toJson<double>(pitch),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VoiceProfileRow copyWith({
    String? id,
    String? name,
    String? kind,
    Value<String?> systemVoiceId = const Value.absent(),
    Value<String?> systemVoiceLocale = const Value.absent(),
    Value<String?> sampleAudioPath = const Value.absent(),
    Value<String?> echovoicePath = const Value.absent(),
    double? pitchShift,
    double? speed,
    double? pitch,
    bool? isDefault,
    DateTime? createdAt,
  }) => VoiceProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    systemVoiceId: systemVoiceId.present
        ? systemVoiceId.value
        : this.systemVoiceId,
    systemVoiceLocale: systemVoiceLocale.present
        ? systemVoiceLocale.value
        : this.systemVoiceLocale,
    sampleAudioPath: sampleAudioPath.present
        ? sampleAudioPath.value
        : this.sampleAudioPath,
    echovoicePath: echovoicePath.present
        ? echovoicePath.value
        : this.echovoicePath,
    pitchShift: pitchShift ?? this.pitchShift,
    speed: speed ?? this.speed,
    pitch: pitch ?? this.pitch,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );
  VoiceProfileRow copyWithCompanion(VoiceProfilesCompanion data) {
    return VoiceProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      systemVoiceId: data.systemVoiceId.present
          ? data.systemVoiceId.value
          : this.systemVoiceId,
      systemVoiceLocale: data.systemVoiceLocale.present
          ? data.systemVoiceLocale.value
          : this.systemVoiceLocale,
      sampleAudioPath: data.sampleAudioPath.present
          ? data.sampleAudioPath.value
          : this.sampleAudioPath,
      echovoicePath: data.echovoicePath.present
          ? data.echovoicePath.value
          : this.echovoicePath,
      pitchShift: data.pitchShift.present
          ? data.pitchShift.value
          : this.pitchShift,
      speed: data.speed.present ? data.speed.value : this.speed,
      pitch: data.pitch.present ? data.pitch.value : this.pitch,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('systemVoiceId: $systemVoiceId, ')
          ..write('systemVoiceLocale: $systemVoiceLocale, ')
          ..write('sampleAudioPath: $sampleAudioPath, ')
          ..write('echovoicePath: $echovoicePath, ')
          ..write('pitchShift: $pitchShift, ')
          ..write('speed: $speed, ')
          ..write('pitch: $pitch, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    systemVoiceId,
    systemVoiceLocale,
    sampleAudioPath,
    echovoicePath,
    pitchShift,
    speed,
    pitch,
    isDefault,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.systemVoiceId == this.systemVoiceId &&
          other.systemVoiceLocale == this.systemVoiceLocale &&
          other.sampleAudioPath == this.sampleAudioPath &&
          other.echovoicePath == this.echovoicePath &&
          other.pitchShift == this.pitchShift &&
          other.speed == this.speed &&
          other.pitch == this.pitch &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class VoiceProfilesCompanion extends UpdateCompanion<VoiceProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> systemVoiceId;
  final Value<String?> systemVoiceLocale;
  final Value<String?> sampleAudioPath;
  final Value<String?> echovoicePath;
  final Value<double> pitchShift;
  final Value<double> speed;
  final Value<double> pitch;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VoiceProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.systemVoiceId = const Value.absent(),
    this.systemVoiceLocale = const Value.absent(),
    this.sampleAudioPath = const Value.absent(),
    this.echovoicePath = const Value.absent(),
    this.pitchShift = const Value.absent(),
    this.speed = const Value.absent(),
    this.pitch = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceProfilesCompanion.insert({
    required String id,
    required String name,
    required String kind,
    this.systemVoiceId = const Value.absent(),
    this.systemVoiceLocale = const Value.absent(),
    this.sampleAudioPath = const Value.absent(),
    this.echovoicePath = const Value.absent(),
    this.pitchShift = const Value.absent(),
    this.speed = const Value.absent(),
    this.pitch = const Value.absent(),
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<VoiceProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? systemVoiceId,
    Expression<String>? systemVoiceLocale,
    Expression<String>? sampleAudioPath,
    Expression<String>? echovoicePath,
    Expression<double>? pitchShift,
    Expression<double>? speed,
    Expression<double>? pitch,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (systemVoiceId != null) 'system_voice_id': systemVoiceId,
      if (systemVoiceLocale != null) 'system_voice_locale': systemVoiceLocale,
      if (sampleAudioPath != null) 'sample_audio_path': sampleAudioPath,
      if (echovoicePath != null) 'echovoice_path': echovoicePath,
      if (pitchShift != null) 'pitch_shift': pitchShift,
      if (speed != null) 'speed': speed,
      if (pitch != null) 'pitch': pitch,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? systemVoiceId,
    Value<String?>? systemVoiceLocale,
    Value<String?>? sampleAudioPath,
    Value<String?>? echovoicePath,
    Value<double>? pitchShift,
    Value<double>? speed,
    Value<double>? pitch,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VoiceProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      systemVoiceId: systemVoiceId ?? this.systemVoiceId,
      systemVoiceLocale: systemVoiceLocale ?? this.systemVoiceLocale,
      sampleAudioPath: sampleAudioPath ?? this.sampleAudioPath,
      echovoicePath: echovoicePath ?? this.echovoicePath,
      pitchShift: pitchShift ?? this.pitchShift,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (systemVoiceId.present) {
      map['system_voice_id'] = Variable<String>(systemVoiceId.value);
    }
    if (systemVoiceLocale.present) {
      map['system_voice_locale'] = Variable<String>(systemVoiceLocale.value);
    }
    if (sampleAudioPath.present) {
      map['sample_audio_path'] = Variable<String>(sampleAudioPath.value);
    }
    if (echovoicePath.present) {
      map['echovoice_path'] = Variable<String>(echovoicePath.value);
    }
    if (pitchShift.present) {
      map['pitch_shift'] = Variable<double>(pitchShift.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (pitch.present) {
      map['pitch'] = Variable<double>(pitch.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('systemVoiceId: $systemVoiceId, ')
          ..write('systemVoiceLocale: $systemVoiceLocale, ')
          ..write('sampleAudioPath: $sampleAudioPath, ')
          ..write('echovoicePath: $echovoicePath, ')
          ..write('pitchShift: $pitchShift, ')
          ..write('speed: $speed, ')
          ..write('pitch: $pitch, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportJobsTable extends ExportJobs
    with TableInfo<$ExportJobsTable, ExportJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voiceProfileIdMeta = const VerificationMeta(
    'voiceProfileId',
  );
  @override
  late final GeneratedColumn<String> voiceProfileId = GeneratedColumn<String>(
    'voice_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeTypeMeta = const VerificationMeta(
    'scopeType',
  );
  @override
  late final GeneratedColumn<String> scopeType = GeneratedColumn<String>(
    'scope_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeJsonMeta = const VerificationMeta(
    'scopeJson',
  );
  @override
  late final GeneratedColumn<String> scopeJson = GeneratedColumn<String>(
    'scope_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outputPathMeta = const VerificationMeta(
    'outputPath',
  );
  @override
  late final GeneratedColumn<String> outputPath = GeneratedColumn<String>(
    'output_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedBytesMeta = const VerificationMeta(
    'estimatedBytes',
  );
  @override
  late final GeneratedColumn<int> estimatedBytes = GeneratedColumn<int>(
    'estimated_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    voiceProfileId,
    scopeType,
    scopeJson,
    speed,
    format,
    status,
    progress,
    outputPath,
    estimatedBytes,
    errorMessage,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('voice_profile_id')) {
      context.handle(
        _voiceProfileIdMeta,
        voiceProfileId.isAcceptableOrUnknown(
          data['voice_profile_id']!,
          _voiceProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voiceProfileIdMeta);
    }
    if (data.containsKey('scope_type')) {
      context.handle(
        _scopeTypeMeta,
        scopeType.isAcceptableOrUnknown(data['scope_type']!, _scopeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeTypeMeta);
    }
    if (data.containsKey('scope_json')) {
      context.handle(
        _scopeJsonMeta,
        scopeJson.isAcceptableOrUnknown(data['scope_json']!, _scopeJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeJsonMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('output_path')) {
      context.handle(
        _outputPathMeta,
        outputPath.isAcceptableOrUnknown(data['output_path']!, _outputPathMeta),
      );
    }
    if (data.containsKey('estimated_bytes')) {
      context.handle(
        _estimatedBytesMeta,
        estimatedBytes.isAcceptableOrUnknown(
          data['estimated_bytes']!,
          _estimatedBytesMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportJobRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      voiceProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_profile_id'],
      )!,
      scopeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_type'],
      )!,
      scopeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_json'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      outputPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_path'],
      ),
      estimatedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_bytes'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ExportJobsTable createAlias(String alias) {
    return $ExportJobsTable(attachedDatabase, alias);
  }
}

class ExportJobRow extends DataClass implements Insertable<ExportJobRow> {
  final String id;
  final String bookId;
  final String voiceProfileId;
  final String scopeType;
  final String scopeJson;
  final double speed;
  final String format;
  final String status;
  final double progress;
  final String? outputPath;
  final int? estimatedBytes;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  const ExportJobRow({
    required this.id,
    required this.bookId,
    required this.voiceProfileId,
    required this.scopeType,
    required this.scopeJson,
    required this.speed,
    required this.format,
    required this.status,
    required this.progress,
    this.outputPath,
    this.estimatedBytes,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['voice_profile_id'] = Variable<String>(voiceProfileId);
    map['scope_type'] = Variable<String>(scopeType);
    map['scope_json'] = Variable<String>(scopeJson);
    map['speed'] = Variable<double>(speed);
    map['format'] = Variable<String>(format);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || outputPath != null) {
      map['output_path'] = Variable<String>(outputPath);
    }
    if (!nullToAbsent || estimatedBytes != null) {
      map['estimated_bytes'] = Variable<int>(estimatedBytes);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ExportJobsCompanion toCompanion(bool nullToAbsent) {
    return ExportJobsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      voiceProfileId: Value(voiceProfileId),
      scopeType: Value(scopeType),
      scopeJson: Value(scopeJson),
      speed: Value(speed),
      format: Value(format),
      status: Value(status),
      progress: Value(progress),
      outputPath: outputPath == null && nullToAbsent
          ? const Value.absent()
          : Value(outputPath),
      estimatedBytes: estimatedBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedBytes),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ExportJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportJobRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      voiceProfileId: serializer.fromJson<String>(json['voiceProfileId']),
      scopeType: serializer.fromJson<String>(json['scopeType']),
      scopeJson: serializer.fromJson<String>(json['scopeJson']),
      speed: serializer.fromJson<double>(json['speed']),
      format: serializer.fromJson<String>(json['format']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      outputPath: serializer.fromJson<String?>(json['outputPath']),
      estimatedBytes: serializer.fromJson<int?>(json['estimatedBytes']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'voiceProfileId': serializer.toJson<String>(voiceProfileId),
      'scopeType': serializer.toJson<String>(scopeType),
      'scopeJson': serializer.toJson<String>(scopeJson),
      'speed': serializer.toJson<double>(speed),
      'format': serializer.toJson<String>(format),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'outputPath': serializer.toJson<String?>(outputPath),
      'estimatedBytes': serializer.toJson<int?>(estimatedBytes),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ExportJobRow copyWith({
    String? id,
    String? bookId,
    String? voiceProfileId,
    String? scopeType,
    String? scopeJson,
    double? speed,
    String? format,
    String? status,
    double? progress,
    Value<String?> outputPath = const Value.absent(),
    Value<int?> estimatedBytes = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ExportJobRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    voiceProfileId: voiceProfileId ?? this.voiceProfileId,
    scopeType: scopeType ?? this.scopeType,
    scopeJson: scopeJson ?? this.scopeJson,
    speed: speed ?? this.speed,
    format: format ?? this.format,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    outputPath: outputPath.present ? outputPath.value : this.outputPath,
    estimatedBytes: estimatedBytes.present
        ? estimatedBytes.value
        : this.estimatedBytes,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ExportJobRow copyWithCompanion(ExportJobsCompanion data) {
    return ExportJobRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      voiceProfileId: data.voiceProfileId.present
          ? data.voiceProfileId.value
          : this.voiceProfileId,
      scopeType: data.scopeType.present ? data.scopeType.value : this.scopeType,
      scopeJson: data.scopeJson.present ? data.scopeJson.value : this.scopeJson,
      speed: data.speed.present ? data.speed.value : this.speed,
      format: data.format.present ? data.format.value : this.format,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      outputPath: data.outputPath.present
          ? data.outputPath.value
          : this.outputPath,
      estimatedBytes: data.estimatedBytes.present
          ? data.estimatedBytes.value
          : this.estimatedBytes,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportJobRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('voiceProfileId: $voiceProfileId, ')
          ..write('scopeType: $scopeType, ')
          ..write('scopeJson: $scopeJson, ')
          ..write('speed: $speed, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('outputPath: $outputPath, ')
          ..write('estimatedBytes: $estimatedBytes, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    voiceProfileId,
    scopeType,
    scopeJson,
    speed,
    format,
    status,
    progress,
    outputPath,
    estimatedBytes,
    errorMessage,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportJobRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.voiceProfileId == this.voiceProfileId &&
          other.scopeType == this.scopeType &&
          other.scopeJson == this.scopeJson &&
          other.speed == this.speed &&
          other.format == this.format &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.outputPath == this.outputPath &&
          other.estimatedBytes == this.estimatedBytes &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class ExportJobsCompanion extends UpdateCompanion<ExportJobRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> voiceProfileId;
  final Value<String> scopeType;
  final Value<String> scopeJson;
  final Value<double> speed;
  final Value<String> format;
  final Value<String> status;
  final Value<double> progress;
  final Value<String?> outputPath;
  final Value<int?> estimatedBytes;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ExportJobsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.voiceProfileId = const Value.absent(),
    this.scopeType = const Value.absent(),
    this.scopeJson = const Value.absent(),
    this.speed = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.estimatedBytes = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportJobsCompanion.insert({
    required String id,
    required String bookId,
    required String voiceProfileId,
    required String scopeType,
    required String scopeJson,
    this.speed = const Value.absent(),
    required String format,
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.estimatedBytes = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       voiceProfileId = Value(voiceProfileId),
       scopeType = Value(scopeType),
       scopeJson = Value(scopeJson),
       format = Value(format),
       createdAt = Value(createdAt);
  static Insertable<ExportJobRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? voiceProfileId,
    Expression<String>? scopeType,
    Expression<String>? scopeJson,
    Expression<double>? speed,
    Expression<String>? format,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? outputPath,
    Expression<int>? estimatedBytes,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (voiceProfileId != null) 'voice_profile_id': voiceProfileId,
      if (scopeType != null) 'scope_type': scopeType,
      if (scopeJson != null) 'scope_json': scopeJson,
      if (speed != null) 'speed': speed,
      if (format != null) 'format': format,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (outputPath != null) 'output_path': outputPath,
      if (estimatedBytes != null) 'estimated_bytes': estimatedBytes,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? voiceProfileId,
    Value<String>? scopeType,
    Value<String>? scopeJson,
    Value<double>? speed,
    Value<String>? format,
    Value<String>? status,
    Value<double>? progress,
    Value<String?>? outputPath,
    Value<int?>? estimatedBytes,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ExportJobsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      voiceProfileId: voiceProfileId ?? this.voiceProfileId,
      scopeType: scopeType ?? this.scopeType,
      scopeJson: scopeJson ?? this.scopeJson,
      speed: speed ?? this.speed,
      format: format ?? this.format,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      outputPath: outputPath ?? this.outputPath,
      estimatedBytes: estimatedBytes ?? this.estimatedBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (voiceProfileId.present) {
      map['voice_profile_id'] = Variable<String>(voiceProfileId.value);
    }
    if (scopeType.present) {
      map['scope_type'] = Variable<String>(scopeType.value);
    }
    if (scopeJson.present) {
      map['scope_json'] = Variable<String>(scopeJson.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (outputPath.present) {
      map['output_path'] = Variable<String>(outputPath.value);
    }
    if (estimatedBytes.present) {
      map['estimated_bytes'] = Variable<int>(estimatedBytes.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportJobsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('voiceProfileId: $voiceProfileId, ')
          ..write('scopeType: $scopeType, ')
          ..write('scopeJson: $scopeJson, ')
          ..write('speed: $speed, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('outputPath: $outputPath, ')
          ..write('estimatedBytes: $estimatedBytes, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ReadingProgressTableTable readingProgressTable =
      $ReadingProgressTableTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $VoiceProfilesTable voiceProfiles = $VoiceProfilesTable(this);
  late final $ExportJobsTable exportJobs = $ExportJobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    readingProgressTable,
    bookmarks,
    voiceProfiles,
    exportJobs,
  ];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      required String title,
      Value<String> author,
      required String format,
      required String filePath,
      Value<String?> coverPath,
      Value<int> chapterCount,
      Value<int> wordCount,
      required DateTime importedAt,
      Value<DateTime?> lastOpenedAt,
      Value<String?> contentCachePath,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> author,
      Value<String> format,
      Value<String> filePath,
      Value<String?> coverPath,
      Value<int> chapterCount,
      Value<int> wordCount,
      Value<DateTime> importedAt,
      Value<DateTime?> lastOpenedAt,
      Value<String?> contentCachePath,
      Value<int> rowid,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentCachePath => $composableBuilder(
    column: $table.contentCachePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentCachePath => $composableBuilder(
    column: $table.contentCachePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentCachePath => $composableBuilder(
    column: $table.contentCachePath,
    builder: (column) => column,
  );
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookRow,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookRow, BaseReferences<_$AppDatabase, $BooksTable, BookRow>),
          BookRow,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int> chapterCount = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<String?> contentCachePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                format: format,
                filePath: filePath,
                coverPath: coverPath,
                chapterCount: chapterCount,
                wordCount: wordCount,
                importedAt: importedAt,
                lastOpenedAt: lastOpenedAt,
                contentCachePath: contentCachePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> author = const Value.absent(),
                required String format,
                required String filePath,
                Value<String?> coverPath = const Value.absent(),
                Value<int> chapterCount = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                required DateTime importedAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<String?> contentCachePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                format: format,
                filePath: filePath,
                coverPath: coverPath,
                chapterCount: chapterCount,
                wordCount: wordCount,
                importedAt: importedAt,
                lastOpenedAt: lastOpenedAt,
                contentCachePath: contentCachePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookRow,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookRow, BaseReferences<_$AppDatabase, $BooksTable, BookRow>),
      BookRow,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressTableTableCreateCompanionBuilder =
    ReadingProgressTableCompanion Function({
      required String bookId,
      Value<int> chapterIndex,
      Value<double> chapterFraction,
      Value<double> overallFraction,
      Value<int> characterOffset,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ReadingProgressTableTableUpdateCompanionBuilder =
    ReadingProgressTableCompanion Function({
      Value<String> bookId,
      Value<int> chapterIndex,
      Value<double> chapterFraction,
      Value<double> overallFraction,
      Value<int> characterOffset,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ReadingProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chapterFraction => $composableBuilder(
    column: $table.chapterFraction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallFraction => $composableBuilder(
    column: $table.overallFraction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterOffset => $composableBuilder(
    column: $table.characterOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chapterFraction => $composableBuilder(
    column: $table.chapterFraction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallFraction => $composableBuilder(
    column: $table.overallFraction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterOffset => $composableBuilder(
    column: $table.characterOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chapterFraction => $composableBuilder(
    column: $table.chapterFraction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallFraction => $composableBuilder(
    column: $table.overallFraction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get characterOffset => $composableBuilder(
    column: $table.characterOffset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressTableTable,
          ReadingProgressRow,
          $$ReadingProgressTableTableFilterComposer,
          $$ReadingProgressTableTableOrderingComposer,
          $$ReadingProgressTableTableAnnotationComposer,
          $$ReadingProgressTableTableCreateCompanionBuilder,
          $$ReadingProgressTableTableUpdateCompanionBuilder,
          (
            ReadingProgressRow,
            BaseReferences<
              _$AppDatabase,
              $ReadingProgressTableTable,
              ReadingProgressRow
            >,
          ),
          ReadingProgressRow,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableTableManager(
    _$AppDatabase db,
    $ReadingProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<double> chapterFraction = const Value.absent(),
                Value<double> overallFraction = const Value.absent(),
                Value<int> characterOffset = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressTableCompanion(
                bookId: bookId,
                chapterIndex: chapterIndex,
                chapterFraction: chapterFraction,
                overallFraction: overallFraction,
                characterOffset: characterOffset,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                Value<int> chapterIndex = const Value.absent(),
                Value<double> chapterFraction = const Value.absent(),
                Value<double> overallFraction = const Value.absent(),
                Value<int> characterOffset = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressTableCompanion.insert(
                bookId: bookId,
                chapterIndex: chapterIndex,
                chapterFraction: chapterFraction,
                overallFraction: overallFraction,
                characterOffset: characterOffset,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressTableTable,
      ReadingProgressRow,
      $$ReadingProgressTableTableFilterComposer,
      $$ReadingProgressTableTableOrderingComposer,
      $$ReadingProgressTableTableAnnotationComposer,
      $$ReadingProgressTableTableCreateCompanionBuilder,
      $$ReadingProgressTableTableUpdateCompanionBuilder,
      (
        ReadingProgressRow,
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressTableTable,
          ReadingProgressRow
        >,
      ),
      ReadingProgressRow,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String id,
      required String bookId,
      required int chapterIndex,
      required int characterOffset,
      required String excerpt,
      Value<String?> label,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> chapterIndex,
      Value<int> characterOffset,
      Value<String> excerpt,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterOffset => $composableBuilder(
    column: $table.characterOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterOffset => $composableBuilder(
    column: $table.characterOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get characterOffset => $composableBuilder(
    column: $table.characterOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkRow,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (
            BookmarkRow,
            BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>,
          ),
          BookmarkRow,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<int> characterOffset = const Value.absent(),
                Value<String> excerpt = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                characterOffset: characterOffset,
                excerpt: excerpt,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int chapterIndex,
                required int characterOffset,
                required String excerpt,
                Value<String?> label = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                characterOffset: characterOffset,
                excerpt: excerpt,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkRow,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (
        BookmarkRow,
        BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>,
      ),
      BookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$VoiceProfilesTableCreateCompanionBuilder =
    VoiceProfilesCompanion Function({
      required String id,
      required String name,
      required String kind,
      Value<String?> systemVoiceId,
      Value<String?> systemVoiceLocale,
      Value<String?> sampleAudioPath,
      Value<String?> echovoicePath,
      Value<double> pitchShift,
      Value<double> speed,
      Value<double> pitch,
      Value<bool> isDefault,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$VoiceProfilesTableUpdateCompanionBuilder =
    VoiceProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<String?> systemVoiceId,
      Value<String?> systemVoiceLocale,
      Value<String?> sampleAudioPath,
      Value<String?> echovoicePath,
      Value<double> pitchShift,
      Value<double> speed,
      Value<double> pitch,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VoiceProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceProfilesTable> {
  $$VoiceProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemVoiceId => $composableBuilder(
    column: $table.systemVoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemVoiceLocale => $composableBuilder(
    column: $table.systemVoiceLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sampleAudioPath => $composableBuilder(
    column: $table.sampleAudioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get echovoicePath => $composableBuilder(
    column: $table.echovoicePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pitchShift => $composableBuilder(
    column: $table.pitchShift,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pitch => $composableBuilder(
    column: $table.pitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoiceProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceProfilesTable> {
  $$VoiceProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemVoiceId => $composableBuilder(
    column: $table.systemVoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemVoiceLocale => $composableBuilder(
    column: $table.systemVoiceLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sampleAudioPath => $composableBuilder(
    column: $table.sampleAudioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get echovoicePath => $composableBuilder(
    column: $table.echovoicePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pitchShift => $composableBuilder(
    column: $table.pitchShift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pitch => $composableBuilder(
    column: $table.pitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoiceProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceProfilesTable> {
  $$VoiceProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get systemVoiceId => $composableBuilder(
    column: $table.systemVoiceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemVoiceLocale => $composableBuilder(
    column: $table.systemVoiceLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sampleAudioPath => $composableBuilder(
    column: $table.sampleAudioPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get echovoicePath => $composableBuilder(
    column: $table.echovoicePath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pitchShift => $composableBuilder(
    column: $table.pitchShift,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get pitch =>
      $composableBuilder(column: $table.pitch, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VoiceProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceProfilesTable,
          VoiceProfileRow,
          $$VoiceProfilesTableFilterComposer,
          $$VoiceProfilesTableOrderingComposer,
          $$VoiceProfilesTableAnnotationComposer,
          $$VoiceProfilesTableCreateCompanionBuilder,
          $$VoiceProfilesTableUpdateCompanionBuilder,
          (
            VoiceProfileRow,
            BaseReferences<_$AppDatabase, $VoiceProfilesTable, VoiceProfileRow>,
          ),
          VoiceProfileRow,
          PrefetchHooks Function()
        > {
  $$VoiceProfilesTableTableManager(_$AppDatabase db, $VoiceProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> systemVoiceId = const Value.absent(),
                Value<String?> systemVoiceLocale = const Value.absent(),
                Value<String?> sampleAudioPath = const Value.absent(),
                Value<String?> echovoicePath = const Value.absent(),
                Value<double> pitchShift = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<double> pitch = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoiceProfilesCompanion(
                id: id,
                name: name,
                kind: kind,
                systemVoiceId: systemVoiceId,
                systemVoiceLocale: systemVoiceLocale,
                sampleAudioPath: sampleAudioPath,
                echovoicePath: echovoicePath,
                pitchShift: pitchShift,
                speed: speed,
                pitch: pitch,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                Value<String?> systemVoiceId = const Value.absent(),
                Value<String?> systemVoiceLocale = const Value.absent(),
                Value<String?> sampleAudioPath = const Value.absent(),
                Value<String?> echovoicePath = const Value.absent(),
                Value<double> pitchShift = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<double> pitch = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VoiceProfilesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                systemVoiceId: systemVoiceId,
                systemVoiceLocale: systemVoiceLocale,
                sampleAudioPath: sampleAudioPath,
                echovoicePath: echovoicePath,
                pitchShift: pitchShift,
                speed: speed,
                pitch: pitch,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VoiceProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceProfilesTable,
      VoiceProfileRow,
      $$VoiceProfilesTableFilterComposer,
      $$VoiceProfilesTableOrderingComposer,
      $$VoiceProfilesTableAnnotationComposer,
      $$VoiceProfilesTableCreateCompanionBuilder,
      $$VoiceProfilesTableUpdateCompanionBuilder,
      (
        VoiceProfileRow,
        BaseReferences<_$AppDatabase, $VoiceProfilesTable, VoiceProfileRow>,
      ),
      VoiceProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ExportJobsTableCreateCompanionBuilder =
    ExportJobsCompanion Function({
      required String id,
      required String bookId,
      required String voiceProfileId,
      required String scopeType,
      required String scopeJson,
      Value<double> speed,
      required String format,
      Value<String> status,
      Value<double> progress,
      Value<String?> outputPath,
      Value<int?> estimatedBytes,
      Value<String?> errorMessage,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ExportJobsTableUpdateCompanionBuilder =
    ExportJobsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> voiceProfileId,
      Value<String> scopeType,
      Value<String> scopeJson,
      Value<double> speed,
      Value<String> format,
      Value<String> status,
      Value<double> progress,
      Value<String?> outputPath,
      Value<int?> estimatedBytes,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$ExportJobsTableFilterComposer
    extends Composer<_$AppDatabase, $ExportJobsTable> {
  $$ExportJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceProfileId => $composableBuilder(
    column: $table.voiceProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeType => $composableBuilder(
    column: $table.scopeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeJson => $composableBuilder(
    column: $table.scopeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedBytes => $composableBuilder(
    column: $table.estimatedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportJobsTable> {
  $$ExportJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceProfileId => $composableBuilder(
    column: $table.voiceProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeType => $composableBuilder(
    column: $table.scopeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeJson => $composableBuilder(
    column: $table.scopeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedBytes => $composableBuilder(
    column: $table.estimatedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportJobsTable> {
  $$ExportJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get voiceProfileId => $composableBuilder(
    column: $table.voiceProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopeType =>
      $composableBuilder(column: $table.scopeType, builder: (column) => column);

  GeneratedColumn<String> get scopeJson =>
      $composableBuilder(column: $table.scopeJson, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedBytes => $composableBuilder(
    column: $table.estimatedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ExportJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportJobsTable,
          ExportJobRow,
          $$ExportJobsTableFilterComposer,
          $$ExportJobsTableOrderingComposer,
          $$ExportJobsTableAnnotationComposer,
          $$ExportJobsTableCreateCompanionBuilder,
          $$ExportJobsTableUpdateCompanionBuilder,
          (
            ExportJobRow,
            BaseReferences<_$AppDatabase, $ExportJobsTable, ExportJobRow>,
          ),
          ExportJobRow,
          PrefetchHooks Function()
        > {
  $$ExportJobsTableTableManager(_$AppDatabase db, $ExportJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> voiceProfileId = const Value.absent(),
                Value<String> scopeType = const Value.absent(),
                Value<String> scopeJson = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> outputPath = const Value.absent(),
                Value<int?> estimatedBytes = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportJobsCompanion(
                id: id,
                bookId: bookId,
                voiceProfileId: voiceProfileId,
                scopeType: scopeType,
                scopeJson: scopeJson,
                speed: speed,
                format: format,
                status: status,
                progress: progress,
                outputPath: outputPath,
                estimatedBytes: estimatedBytes,
                errorMessage: errorMessage,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String voiceProfileId,
                required String scopeType,
                required String scopeJson,
                Value<double> speed = const Value.absent(),
                required String format,
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> outputPath = const Value.absent(),
                Value<int?> estimatedBytes = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportJobsCompanion.insert(
                id: id,
                bookId: bookId,
                voiceProfileId: voiceProfileId,
                scopeType: scopeType,
                scopeJson: scopeJson,
                speed: speed,
                format: format,
                status: status,
                progress: progress,
                outputPath: outputPath,
                estimatedBytes: estimatedBytes,
                errorMessage: errorMessage,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportJobsTable,
      ExportJobRow,
      $$ExportJobsTableFilterComposer,
      $$ExportJobsTableOrderingComposer,
      $$ExportJobsTableAnnotationComposer,
      $$ExportJobsTableCreateCompanionBuilder,
      $$ExportJobsTableUpdateCompanionBuilder,
      (
        ExportJobRow,
        BaseReferences<_$AppDatabase, $ExportJobsTable, ExportJobRow>,
      ),
      ExportJobRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ReadingProgressTableTableTableManager get readingProgressTable =>
      $$ReadingProgressTableTableTableManager(_db, _db.readingProgressTable);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$VoiceProfilesTableTableManager get voiceProfiles =>
      $$VoiceProfilesTableTableManager(_db, _db.voiceProfiles);
  $$ExportJobsTableTableManager get exportJobs =>
      $$ExportJobsTableTableManager(_db, _db.exportJobs);
}
