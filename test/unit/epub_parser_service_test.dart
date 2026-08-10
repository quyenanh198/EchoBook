import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:echobook/services/parsing/epub_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Builds a minimal, valid EPUB2 file (mimetype + container.xml + OPF +
/// NCX + two XHTML chapters) so parsing can be tested against a real zip
/// archive rather than mocked internals.
Future<String> _buildFixtureEpub(String path) async {
  final archive = Archive();

  void addFile(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  addFile('mimetype', 'application/epub+zip');

  addFile('META-INF/container.xml', '''
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''');

  addFile('OEBPS/content.opf', '''
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookId" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Test Fixture Book</dc:title>
    <dc:creator>Fixture Author</dc:creator>
    <dc:identifier id="BookId">urn:uuid:fixture-0001</dc:identifier>
    <dc:language>en</dc:language>
  </metadata>
  <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="chapter1" href="chapter1.xhtml" media-type="application/xhtml+xml"/>
    <item id="chapter2" href="chapter2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine toc="ncx">
    <itemref idref="chapter1"/>
    <itemref idref="chapter2"/>
  </spine>
</package>
''');

  addFile('OEBPS/toc.ncx', '''
<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="urn:uuid:fixture-0001"/>
  </head>
  <docTitle><text>Test Fixture Book</text></docTitle>
  <navMap>
    <navPoint id="np1" playOrder="1">
      <navLabel><text>Chapter One</text></navLabel>
      <content src="chapter1.xhtml"/>
    </navPoint>
    <navPoint id="np2" playOrder="2">
      <navLabel><text>Chapter Two</text></navLabel>
      <content src="chapter2.xhtml"/>
    </navPoint>
  </navMap>
</ncx>
''');

  addFile('OEBPS/chapter1.xhtml', '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<body><p>This is the first chapter of the fixture book.</p></body>
</html>
''');

  addFile('OEBPS/chapter2.xhtml', '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<body><p>This is the second chapter, with more content.</p></body>
</html>
''');

  final bytes = ZipEncoder().encode(archive)!;
  await File(path).writeAsBytes(bytes);
  return path;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('echobook_epub_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('supports only .epub extension', () {
    final parser = EpubParserService();
    expect(parser.supports('epub'), isTrue);
    expect(parser.supports('EPUB'), isTrue);
    expect(parser.supports('pdf'), isFalse);
  });

  test('extracts title, author and chapters from a real EPUB archive', () async {
    final path = await _buildFixtureEpub(p.join(tempDir.path, 'fixture.epub'));

    final book = await EpubParserService().parse(path);

    expect(book.title, 'Test Fixture Book');
    expect(book.author, 'Fixture Author');
    expect(book.chapters.length, 2);
    expect(book.chapters[0].title, 'Chapter One');
    expect(book.chapters[0].plainText, contains('first chapter'));
    expect(book.chapters[1].title, 'Chapter Two');
    expect(book.chapters[1].plainText, contains('second chapter'));
  });
}
