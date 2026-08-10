import 'dart:convert';
import 'dart:io';

import 'parsed_book.dart';

/// Persists parsed chapter text next to the original file so the Reader and
/// TTS/export pipeline never need to re-parse EPUB/PDF content after import.
class ContentCache {
  static Future<void> write(String path, List<ParsedChapter> chapters) async {
    final json = jsonEncode(chapters.map((c) => {'title': c.title, 'text': c.plainText}).toList());
    await File(path).writeAsString(json);
  }

  static Future<List<ParsedChapter>> read(String path) async {
    final json = jsonDecode(await File(path).readAsString()) as List;
    return json
        .cast<Map<String, dynamic>>()
        .map((m) => ParsedChapter(title: m['title'] as String, plainText: m['text'] as String))
        .toList();
  }
}
