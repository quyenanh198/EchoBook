import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Converts EPUB XHTML chapter content to clean, paragraph-separated plain
/// text suitable for the reflowable reader and sentence-level TTS.
String htmlToPlainText(String htmlSource) {
  final document = html_parser.parse(htmlSource);
  final buffer = StringBuffer();
  _walk(document.body ?? document.documentElement, buffer);
  return buffer
      .toString()
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

const _blockTags = {
  'p', 'div', 'br', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'li', 'blockquote', 'section', 'article', 'tr',
};

void _walk(Node? node, StringBuffer buffer) {
  if (node == null) return;
  if (node is Text) {
    buffer.write(node.text);
    return;
  }
  if (node is Element) {
    final tag = node.localName?.toLowerCase();
    if (tag == 'script' || tag == 'style') return;
    for (final child in node.nodes) {
      _walk(child, buffer);
    }
    if (_blockTags.contains(tag)) {
      buffer.write('\n\n');
    }
  }
}
