import 'package:echobook/core/utils/sentence_splitter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentenceSplitter.split', () {
    test('splits basic sentences on terminators', () {
      final sentences = SentenceSplitter.split('Hello world. How are you? I am fine!');
      expect(sentences.map((s) => s.text).toList(), [
        'Hello world.',
        'How are you?',
        'I am fine!',
      ]);
    });

    test('does not split on decimal numbers', () {
      final sentences = SentenceSplitter.split('Pi is about 3.14 today. Next sentence.');
      expect(sentences.length, 2);
      expect(sentences[0].text, 'Pi is about 3.14 today.');
    });

    test('does not split on common abbreviations', () {
      final sentences = SentenceSplitter.split('Dr. Smith arrived. He was late.');
      expect(sentences.length, 2);
      expect(sentences[0].text, 'Dr. Smith arrived.');
    });

    test('splits on paragraph breaks even without punctuation', () {
      final sentences = SentenceSplitter.split('First line\nSecond line');
      expect(sentences.length, 2);
    });

    test('returns empty list for blank input', () {
      expect(SentenceSplitter.split('   '), isEmpty);
    });

    test('offsets map back to the original string', () {
      const text = 'One. Two. Three.';
      final sentences = SentenceSplitter.split(text);
      for (final s in sentences) {
        expect(text.substring(s.start, s.end), s.text);
      }
    });
  });

  group('SentenceSplitter.sentenceIndexAtOffset', () {
    test('finds the sentence containing an offset', () {
      final sentences = SentenceSplitter.split('One. Two. Three.');
      final index = SentenceSplitter.sentenceIndexAtOffset(sentences, sentences[1].start + 1);
      expect(index, 1);
    });

    test('clamps to the last sentence for an out-of-range offset', () {
      final sentences = SentenceSplitter.split('One. Two.');
      final index = SentenceSplitter.sentenceIndexAtOffset(sentences, 9999);
      expect(index, sentences.length - 1);
    });

    test('returns 0 for empty sentence list', () {
      expect(SentenceSplitter.sentenceIndexAtOffset(const [], 5), 0);
    });
  });
}
