import 'dart:io';

import 'package:echobook/services/parsing/txt_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('echobook_txt_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('supports only .txt extension', () {
    final parser = TxtParserService();
    expect(parser.supports('txt'), isTrue);
    expect(parser.supports('TXT'), isTrue);
    expect(parser.supports('epub'), isFalse);
  });

  test('splits into chapters using explicit chapter headings', () async {
    final file = File(p.join(tempDir.path, 'book.txt'));
    await file.writeAsString(
      'Chapter 1\nThis is the first chapter body.\n\nChapter 2\nThis is the second chapter body.',
    );

    final book = await TxtParserService().parse(file.path);

    expect(book.chapters.length, 2);
    expect(book.chapters[0].title.toLowerCase(), contains('chapter 1'));
    expect(book.chapters[0].plainText, contains('first chapter body'));
    expect(book.chapters[1].plainText, contains('second chapter body'));
  });

  test('falls back to chunking for unstructured text', () async {
    final file = File(p.join(tempDir.path, 'plain.txt'));
    // Long text with no chapter markers, larger than the internal chunk size.
    final longText = List.generate(2000, (i) => 'word$i').join(' ');
    await file.writeAsString(longText);

    final book = await TxtParserService().parse(file.path);

    expect(book.chapters.length, greaterThan(1));
    final reconstructed = book.chapters.map((c) => c.plainText).join(' ').replaceAll(RegExp(r'\s+'), ' ');
    expect(reconstructed.contains('word0'), isTrue);
    expect(reconstructed.contains('word1999'), isTrue);
  });

  test('short unstructured text stays as a single chapter', () async {
    final file = File(p.join(tempDir.path, 'short.txt'));
    await file.writeAsString('Just a short note with no structure.');

    final book = await TxtParserService().parse(file.path);

    expect(book.chapters.length, 1);
  });

  test('decodes non-UTF8 bytes without throwing', () async {
    final file = File(p.join(tempDir.path, 'latin1.txt'));
    // 0xE9 is not valid standalone UTF-8 but is valid Latin-1 ('é').
    await file.writeAsBytes([0x48, 0x69, 0xE9, 0x2E]);

    final book = await TxtParserService().parse(file.path);

    expect(book.chapters, isNotEmpty);
  });
}
