import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'parsed_book.dart';

/// Extracts plain text from PDF files. Prefers the document's outline
/// (bookmarks) for chapter boundaries; falls back to fixed-size page groups
/// when no outline is present (common for scanned/plain PDFs).
class PdfParserService implements EbookParser {
  static const _pagesPerFallbackChapter = 12;

  @override
  bool supports(String extension) => extension.toLowerCase() == 'pdf';

  @override
  Future<ParsedBook> parse(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(document);
      final pageCount = document.pages.count;
      final title = document.documentInformation.title.trim().isNotEmpty
          ? document.documentInformation.title.trim()
          : p.basenameWithoutExtension(filePath);
      final author = document.documentInformation.author.trim().isNotEmpty
          ? document.documentInformation.author.trim()
          : 'Unknown Author';

      final ranges = _chapterRangesFromOutline(document, pageCount) ??
          _fallbackRanges(pageCount);

      final chapters = <ParsedChapter>[];
      for (final range in ranges) {
        final text = extractor
            .extractText(startPageIndex: range.start, endPageIndex: range.end)
            .trim();
        if (text.isNotEmpty) {
          chapters.add(ParsedChapter(title: range.title, plainText: text));
        }
      }

      return ParsedBook(title: title, author: author, chapters: chapters);
    } finally {
      document.dispose();
    }
  }

  List<_Range>? _chapterRangesFromOutline(PdfDocument document, int pageCount) {
    final bookmarks = document.bookmarks;
    if (bookmarks.count == 0) return null;

    final entries = <(String title, int page)>[];
    for (var i = 0; i < bookmarks.count; i++) {
      final bookmark = bookmarks[i];
      final page = bookmark.destination?.page;
      if (page == null) continue;
      final index = document.pages.indexOf(page);
      if (index < 0) continue;
      entries.add((bookmark.title.trim().isEmpty ? 'Chapter ${i + 1}' : bookmark.title.trim(), index));
    }
    if (entries.length < 2) return null;

    entries.sort((a, b) => a.$2.compareTo(b.$2));
    final ranges = <_Range>[];
    for (var i = 0; i < entries.length; i++) {
      final start = entries[i].$2;
      final end = i + 1 < entries.length ? entries[i + 1].$2 - 1 : pageCount - 1;
      if (end >= start) {
        ranges.add(_Range(entries[i].$1, start, end));
      }
    }
    return ranges.isEmpty ? null : ranges;
  }

  List<_Range> _fallbackRanges(int pageCount) {
    final ranges = <_Range>[];
    var start = 0;
    while (start < pageCount) {
      final end = (start + _pagesPerFallbackChapter - 1).clamp(0, pageCount - 1);
      ranges.add(_Range('Pages ${start + 1}-${end + 1}', start, end));
      start = end + 1;
    }
    return ranges;
  }
}

class _Range {
  final String title;
  final int start;
  final int end;
  _Range(this.title, this.start, this.end);
}
