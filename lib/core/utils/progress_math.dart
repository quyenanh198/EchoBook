import '../../services/parsing/parsed_book.dart';

/// Cumulative character offsets of each chapter's start within the whole
/// book, plus total length — shared by the Reader and the TTS player so
/// "how far through the book am I" is computed identically everywhere.
class BookLengthIndex {
  final List<int> chapterStartOffsets;
  final int totalChars;

  const BookLengthIndex(this.chapterStartOffsets, this.totalChars);

  factory BookLengthIndex.fromChapters(List<ParsedChapter> chapters) {
    final starts = <int>[];
    var running = 0;
    for (final c in chapters) {
      starts.add(running);
      running += c.plainText.length;
    }
    return BookLengthIndex(starts, running == 0 ? 1 : running);
  }

  double overallFraction(int chapterIndex, double chapterFraction) {
    if (chapterIndex < 0 || chapterIndex >= chapterStartOffsets.length) return 0;
    final chapterStart = chapterStartOffsets[chapterIndex];
    final chapterLen = chapterIndex + 1 < chapterStartOffsets.length
        ? chapterStartOffsets[chapterIndex + 1] - chapterStart
        : totalChars - chapterStart;
    final charsInto = chapterFraction.clamp(0, 1) * chapterLen;
    return ((chapterStart + charsInto) / totalChars).clamp(0, 1).toDouble();
  }

  /// Estimated minutes left in the whole book at [wordsPerMinute] reading
  /// speed, given current [chapterIndex]/[chapterFraction].
  int estimatedMinutesLeft(
    List<ParsedChapter> chapters,
    int chapterIndex,
    double chapterFraction, {
    int wordsPerMinute = 200,
  }) {
    final fraction = overallFraction(chapterIndex, chapterFraction);
    final totalWords = chapters.fold(0, (sum, c) => sum + c.wordCount);
    final wordsLeft = totalWords * (1 - fraction);
    return (wordsLeft / wordsPerMinute).ceil();
  }
}
