import 'dart:io';
import 'dart:typed_data';

import 'package:epubx/epubx.dart' as epubx;
import 'package:image/image.dart' as img;

import 'html_to_text.dart';
import 'parsed_book.dart';

class EpubParserService implements EbookParser {
  @override
  bool supports(String extension) => extension.toLowerCase() == 'epub';

  @override
  Future<ParsedBook> parse(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final book = await epubx.EpubReader.readBook(bytes);

    final chapters = <ParsedChapter>[];
    void addChapters(List<epubx.EpubChapter>? list) {
      if (list == null) return;
      for (final chapter in list) {
        final text = htmlToPlainText(chapter.HtmlContent ?? '');
        if (text.trim().isNotEmpty) {
          chapters.add(ParsedChapter(
            title: (chapter.Title?.trim().isNotEmpty ?? false)
                ? chapter.Title!.trim()
                : 'Chapter ${chapters.length + 1}',
            plainText: text,
          ));
        }
        addChapters(chapter.SubChapters);
      }
    }

    addChapters(book.Chapters);

    if (chapters.isEmpty) {
      // Fallback: some EPUBs expose content only through spine HTML files.
      final htmlFiles = book.Content?.Html?.values ?? [];
      var i = 1;
      for (final file in htmlFiles) {
        final text = htmlToPlainText(file.Content ?? '');
        if (text.trim().isNotEmpty) {
          chapters.add(ParsedChapter(title: 'Chapter $i', plainText: text));
          i++;
        }
      }
    }

    Uint8List? cover;
    try {
      final coverImage = book.CoverImage;
      if (coverImage != null) {
        cover = Uint8List.fromList(img.encodePng(coverImage));
      }
    } catch (_) {
      cover = null;
    }

    return ParsedBook(
      title: (book.Title?.trim().isNotEmpty ?? false) ? book.Title!.trim() : 'Untitled',
      author: (book.Author?.trim().isNotEmpty ?? false) ? book.Author!.trim() : 'Unknown Author',
      coverBytes: cover,
      chapters: chapters,
    );
  }
}
