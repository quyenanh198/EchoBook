import 'dart:typed_data';

/// A single navigable chapter extracted from a source ebook, already reduced
/// to plain, reflowable text so the Reader and TTS pipeline can share one
/// representation regardless of source format.
class ParsedChapter {
  final String title;
  final String plainText;

  const ParsedChapter({required this.title, required this.plainText});

  int get wordCount => plainText.isEmpty
      ? 0
      : plainText.trim().split(RegExp(r'\s+')).length;
}

/// Normalized in-memory representation of an imported ebook, produced by any
/// [EbookParser] implementation (EPUB / PDF / TXT).
class ParsedBook {
  final String title;
  final String author;
  final Uint8List? coverBytes;
  final List<ParsedChapter> chapters;

  const ParsedBook({
    required this.title,
    required this.author,
    required this.chapters,
    this.coverBytes,
  });

  int get wordCount => chapters.fold(0, (sum, c) => sum + c.wordCount);
}

abstract class EbookParser {
  /// Returns true if this parser can handle the given file extension
  /// (lowercase, no leading dot — e.g. `epub`).
  bool supports(String extension);

  Future<ParsedBook> parse(String filePath);
}

class UnsupportedEbookFormatException implements Exception {
  final String format;
  UnsupportedEbookFormatException(this.format);

  @override
  String toString() =>
      'Unsupported ebook format: .$format. Try converting it to EPUB, PDF or TXT first (e.g. with Calibre).';
}
