import 'package:path/path.dart' as p;

import 'epub_parser_service.dart';
import 'parsed_book.dart';
import 'pdf_parser_service.dart';
import 'txt_parser_service.dart';

/// Resolves the right [EbookParser] for a file, or throws
/// [UnsupportedEbookFormatException] for formats we can't read directly
/// (currently MOBI/AZW3 — Amazon's proprietary formats have no maintained
/// pure-Dart decoder; users are pointed at Calibre to convert to EPUB).
class EbookParserFactory {
  static final List<EbookParser> _parsers = [
    EpubParserService(),
    PdfParserService(),
    TxtParserService(),
  ];

  static const supportedExtensions = ['epub', 'pdf', 'txt'];
  static const knownUnsupportedExtensions = ['mobi', 'azw3', 'azw'];

  static EbookParser resolve(String filePath) {
    final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
    for (final parser in _parsers) {
      if (parser.supports(ext)) return parser;
    }
    throw UnsupportedEbookFormatException(ext);
  }

  static Future<ParsedBook> parse(String filePath) => resolve(filePath).parse(filePath);
}
