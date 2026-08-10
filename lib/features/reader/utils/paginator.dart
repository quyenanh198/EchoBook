import 'package:flutter/material.dart';

/// Splits chapter text into page-sized character ranges by laying it out
/// once with a [TextPainter] and cutting at line boundaries whenever the
/// accumulated height would exceed the available page height. This gives
/// genuinely content-aware pagination (respects font size / line height /
/// viewport) rather than a fixed character-count guess.
List<int> computePageBreaks({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required double maxHeight,
}) {
  if (text.isEmpty || maxWidth <= 0 || maxHeight <= 0) return [0, text.length];

  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  final lines = painter.computeLineMetrics();
  if (lines.isEmpty) return [0, text.length];

  final breaks = <int>[0];
  double pageTop = 0;

  for (final line in lines) {
    final lineBottom = line.baseline - line.ascent + line.height;
    if (lineBottom - pageTop > maxHeight) {
      final lineTop = line.baseline - line.ascent;
      final offset = painter
          .getPositionForOffset(Offset(0.5, lineTop + 0.5))
          .offset;
      if (offset > breaks.last) {
        breaks.add(offset);
        pageTop = lineTop;
      }
    }
  }

  if (breaks.last != text.length) breaks.add(text.length);
  painter.dispose();
  return breaks;
}
