/// A sentence extracted from chapter text, with its character offsets
/// relative to the start of the chapter — used both for TTS highlighting
/// and for resuming playback/reading at an exact position.
class Sentence {
  final String text;
  final int start;
  final int end;

  const Sentence({required this.text, required this.start, required this.end});
}

/// Lightweight, dependency-free sentence boundary detector.
///
/// Not a full NLP tokenizer, but handles the common cases well enough for
/// TTS pacing and highlighting: '.', '!', '?', and Vietnamese-friendly
/// punctuation, while avoiding false splits on common abbreviations and
/// decimal numbers.
class SentenceSplitter {
  static final _abbreviations = {
    'mr', 'mrs', 'ms', 'dr', 'prof', 'sr', 'jr', 'vs', 'etc', 'e.g', 'i.e',
    'st', 'no', 'ông', 'bà', 'ts', 'ths',
  };

  static List<Sentence> split(String text) {
    if (text.trim().isEmpty) return const [];

    final sentences = <Sentence>[];
    var start = 0;
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(char);

      final isTerminator = char == '.' || char == '!' || char == '?' || char == '\n';
      if (!isTerminator) continue;

      final isParagraphBreak = char == '\n';
      if (!isParagraphBreak) {
        // Don't split on a period that's part of a known abbreviation or a
        // decimal number (e.g. "3.14").
        final prevWord = _lastWord(text, i - 1);
        final nextChar = i + 1 < text.length ? text[i + 1] : '';
        final isDecimal = char == '.' && RegExp(r'\d').hasMatch(nextChar) &&
            prevWord.isNotEmpty && RegExp(r'\d$').hasMatch(prevWord);
        final isAbbrev = char == '.' && _abbreviations.contains(prevWord.toLowerCase());
        if (isDecimal || isAbbrev) continue;

        // Require the terminator to be followed by whitespace/EOF to count
        // as a sentence end (avoids splitting mid-URL, mid-ellipsis, etc.).
        if (nextChar.isNotEmpty && nextChar != ' ' && nextChar != '"' &&
            nextChar != '”' && nextChar != '\n' && nextChar != ')') {
          continue;
        }
      }

      final raw = buffer.toString();
      final trimmed = raw.trim();
      if (trimmed.isNotEmpty) {
        final leadingWs = raw.length - raw.trimLeft().length;
        final sStart = start + leadingWs;
        sentences.add(Sentence(text: trimmed, start: sStart, end: sStart + trimmed.length));
      }
      start = i + 1;
      buffer.clear();
    }

    final remainder = buffer.toString();
    final trimmedRemainder = remainder.trim();
    if (trimmedRemainder.isNotEmpty) {
      final leadingWs = remainder.length - remainder.trimLeft().length;
      final sStart = start + leadingWs;
      sentences.add(Sentence(
        text: trimmedRemainder,
        start: sStart,
        end: sStart + trimmedRemainder.length,
      ));
    }

    return sentences;
  }

  static String _lastWord(String text, int endIndex) {
    var i = endIndex;
    while (i >= 0 && text[i] != ' ' && text[i] != '\n') {
      i--;
    }
    return text.substring(i + 1, endIndex + 1);
  }

  /// Returns the index of the sentence containing [offset], or the closest
  /// following sentence if [offset] falls in whitespace between sentences.
  static int sentenceIndexAtOffset(List<Sentence> sentences, int offset) {
    for (var i = 0; i < sentences.length; i++) {
      if (offset <= sentences[i].end) return i;
    }
    return sentences.isEmpty ? 0 : sentences.length - 1;
  }
}
