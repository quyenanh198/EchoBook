import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/utils/book_paths.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/book_repository.dart';
import '../parsing/content_cache.dart';
import '../parsing/ebook_parser_factory.dart';
import '../parsing/parsed_book.dart';

class ImportResult {
  final BookRow book;
  ImportResult(this.book);
}

class ImportService {
  final BookRepository _bookRepository;
  static const _uuid = Uuid();

  ImportService(this._bookRepository);

  Future<ImportResult> importFromFile(String sourceFilePath) async {
    final extension = p.extension(sourceFilePath).replaceFirst('.', '').toLowerCase();

    // Fail fast with a clear message for known-but-unsupported formats.
    if (EbookParserFactory.knownUnsupportedExtensions.contains(extension)) {
      throw UnsupportedEbookFormatException(extension);
    }

    final id = _uuid.v4();
    final paths = await BookPaths.forBook(id);

    final destPath = paths.originalFile(extension);
    await File(sourceFilePath).copy(destPath);

    final ParsedBook parsed;
    try {
      parsed = await EbookParserFactory.parse(destPath);
    } catch (e) {
      await paths.deleteAll();
      rethrow;
    }

    if (parsed.chapters.isEmpty) {
      await paths.deleteAll();
      throw Exception('No readable text could be extracted from this file.');
    }

    await ContentCache.write(paths.contentCacheFile, parsed.chapters);

    String? coverPath;
    if (parsed.coverBytes != null && parsed.coverBytes!.isNotEmpty) {
      final coverFile = File(paths.coverFile);
      await coverFile.writeAsBytes(parsed.coverBytes!);
      coverPath = coverFile.path;
    }

    final row = BooksCompanion.insert(
      id: id,
      title: parsed.title,
      author: Value(parsed.author),
      format: extension,
      filePath: destPath,
      coverPath: Value(coverPath),
      chapterCount: Value(parsed.chapters.length),
      wordCount: Value(parsed.wordCount),
      importedAt: DateTime.now(),
      contentCachePath: Value(paths.contentCacheFile),
    );

    await _bookRepository.upsert(row);
    final saved = await _bookRepository.getById(id);
    return ImportResult(saved!);
  }
}
