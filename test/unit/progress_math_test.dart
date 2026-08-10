import 'package:echobook/core/utils/progress_math.dart';
import 'package:echobook/services/parsing/parsed_book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final chapters = [
    const ParsedChapter(title: 'Ch1', plainText: 'aaaaaaaaaa'), // 10 chars
    const ParsedChapter(title: 'Ch2', plainText: 'bbbbbbbbbbbbbbbbbbbb'), // 20 chars
    const ParsedChapter(title: 'Ch3', plainText: 'cccccccccccccccccccccccccccccc'), // 30 chars (wait, keep 30)
  ];

  test('overallFraction at the very start of the book is 0', () {
    final index = BookLengthIndex.fromChapters(chapters);
    expect(index.overallFraction(0, 0), 0);
  });

  test('overallFraction at the very end of the book is 1', () {
    final index = BookLengthIndex.fromChapters(chapters);
    expect(index.overallFraction(2, 1), closeTo(1.0, 0.0001));
  });

  test('overallFraction accounts for chapters already completed', () {
    final index = BookLengthIndex.fromChapters(chapters);
    // Fully through chapter 1 (10 chars) out of 60 total = 1/6.
    final fraction = index.overallFraction(1, 0);
    expect(fraction, closeTo(10 / 60, 0.0001));
  });

  test('overallFraction is monotonically increasing within a chapter', () {
    final index = BookLengthIndex.fromChapters(chapters);
    final early = index.overallFraction(1, 0.1);
    final late = index.overallFraction(1, 0.9);
    expect(late, greaterThan(early));
  });

  test('estimatedMinutesLeft decreases as fraction read increases', () {
    // Needs enough words that "minutes left" (rounded up) actually differs
    // between start and end — the char-only fixture above is too short.
    final wordyChapters = [
      ParsedChapter(title: 'Ch1', plainText: List.filled(300, 'word').join(' ')),
      ParsedChapter(title: 'Ch2', plainText: List.filled(300, 'word').join(' ')),
      ParsedChapter(title: 'Ch3', plainText: List.filled(300, 'word').join(' ')),
    ];
    final index = BookLengthIndex.fromChapters(wordyChapters);
    final atStart = index.estimatedMinutesLeft(wordyChapters, 0, 0);
    final atEnd = index.estimatedMinutesLeft(wordyChapters, 2, 0.99);
    expect(atEnd, lessThan(atStart));
  });

  test('handles an empty book without dividing by zero', () {
    final index = BookLengthIndex.fromChapters(const []);
    expect(index.overallFraction(0, 0), 0);
  });
}
