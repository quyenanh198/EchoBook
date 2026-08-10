import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the on-disk layout used to store each imported book's original
/// file, cached parsed content, cover image, and generated exports —
/// everything needed for fully offline operation.
class BookPaths {
  final String bookId;
  final Directory root;

  const BookPaths._(this.bookId, this.root);

  static Future<BookPaths> forBook(String bookId) async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(docs.path, 'books', bookId));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return BookPaths._(bookId, root);
  }

  String originalFile(String extension) => p.join(root.path, 'original.$extension');
  String get contentCacheFile => p.join(root.path, 'content.json');
  String get coverFile => p.join(root.path, 'cover.png');
  String get exportsDir => p.join(root.path, 'exports');

  Future<Directory> ensureExportsDir() async {
    final dir = Directory(exportsDir);
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> deleteAll() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  }
}
