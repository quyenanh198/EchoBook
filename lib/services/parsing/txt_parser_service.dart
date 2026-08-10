import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'parsed_book.dart';

/// Splits a plain text file into pseudo-chapters so it still gets a usable
/// Table of Contents. Prefers explicit "Chapter N" / "CHƯƠNG N" markers;
/// falls back to fixed-size chunking for unstructured text.
class TxtParserService implements EbookParser {
  static final _chapterHeading = RegExp(
    r'^\s*(chapter|chương|ch\.)\s+\S+',
    caseSensitive: false,
  );

  static const _chunkSize = 6000; // characters per fallback chapter

  @override
  bool supports(String extension) => extension.toLowerCase() == 'txt';

  @override
  Future<ParsedBook> parse(String filePath) async {
    final file = File(filePath);
    final raw = await file.readAsBytes();
    final text = _decode(raw);
    final title = p.basenameWithoutExtension(filePath);

    final chapters = _splitByHeadings(text) ?? _chunk(text);

    return ParsedBook(
      title: title,
      author: 'Unknown Author',
      chapters: chapters,
    );
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  List<ParsedChapter>? _splitByHeadings(String text) {
    final lines = text.split('\n');
    final headingIndexes = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_chapterHeading.hasMatch(lines[i])) headingIndexes.add(i);
    }
    if (headingIndexes.length < 2) return null;

    final chapters = <ParsedChapter>[];
    for (var i = 0; i < headingIndexes.length; i++) {
      final start = headingIndexes[i];
      final end = i + 1 < headingIndexes.length ? headingIndexes[i + 1] : lines.length;
      final title = lines[start].trim();
      final body = lines.sublist(start + 1, end).join('\n').trim();
      if (body.isNotEmpty) {
        chapters.add(ParsedChapter(title: title, plainText: body));
      }
    }
    return chapters.isEmpty ? null : chapters;
  }

  List<ParsedChapter> _chunk(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= _chunkSize) {
      return [ParsedChapter(title: 'Full Text', plainText: trimmed)];
    }

    final chapters = <ParsedChapter>[];
    var index = 0;
    var chapterNum = 1;
    while (index < trimmed.length) {
      var end = (index + _chunkSize).clamp(0, trimmed.length);
      if (end < trimmed.length) {
        final nextBreak = trimmed.indexOf('\n\n', end);
        if (nextBreak != -1 && nextBreak - end < 2000) end = nextBreak;
      }
      chapters.add(ParsedChapter(
        title: 'Part $chapterNum',
        plainText: trimmed.substring(index, end).trim(),
      ));
      index = end;
      chapterNum++;
    }
    return chapters;
  }
}
