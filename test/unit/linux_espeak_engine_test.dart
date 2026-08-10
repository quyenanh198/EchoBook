import 'package:echobook/services/tts/linux_espeak_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LinuxEspeakEngine.parseVoicesOutput', () {
    // A captured excerpt of real `espeak-ng --voices` output — includes the
    // three Vietnamese voices espeak-ng ships out of the box, plus a couple
    // of neighbors to exercise the general row shape. No leading blank line,
    // matching the real CLI's stdout (header is line 1).
    const fixture = 'Pty Language       Age/Gender VoiceName          File                 Other Languages\n'
        ' 5  af              --/M      Afrikaans          gmw/af\n'
        ' 2  en-us           --/M      English_(America)  gmw/en-US            (en 3)\n'
        ' 5  vi              --/M      Vietnamese_(Northern) aav/vi\n'
        ' 5  vi-vn-x-central --/M      Vietnamese_(Central) aav/vi-VN-x-central\n'
        ' 5  vi-vn-x-south   --/M      Vietnamese_(Southern) aav/vi-VN-x-south\n';

    test('parses each voice row into a SystemVoice with locale == the -v identifier', () {
      final voices = LinuxEspeakEngine.parseVoicesOutput(fixture);

      expect(voices.map((v) => v.locale),
          containsAll(['af', 'en-us', 'vi', 'vi-vn-x-central', 'vi-vn-x-south']));
    });

    test('includes Vietnamese voices out of the box, with human-readable names', () {
      final voices = LinuxEspeakEngine.parseVoicesOutput(fixture);

      final vietnamese = voices.where((v) => v.locale.startsWith('vi')).toList();
      expect(vietnamese, hasLength(3));
      expect(vietnamese.map((v) => v.name), contains('Vietnamese (Northern)'));
    });

    test('skips the header row and blank lines', () {
      final voices = LinuxEspeakEngine.parseVoicesOutput(fixture);
      expect(voices.any((v) => v.locale == 'Language'), isFalse);
      expect(voices, hasLength(5));
    });

    test('returns an empty list for empty output', () {
      expect(LinuxEspeakEngine.parseVoicesOutput(''), isEmpty);
    });
  });
}
