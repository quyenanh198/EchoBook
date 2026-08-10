import 'package:echobook/services/parsing/html_to_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('strips tags and preserves paragraph breaks', () {
    const html = '<html><body><p>Hello <b>world</b>.</p><p>Second paragraph.</p></body></html>';
    final text = htmlToPlainText(html);
    expect(text, 'Hello world.\n\nSecond paragraph.');
  });

  test('drops script and style content', () {
    const html = '<div><style>.a{color:red}</style><script>alert(1)</script><p>Visible</p></div>';
    final text = htmlToPlainText(html);
    expect(text, 'Visible');
  });

  test('handles empty input', () {
    expect(htmlToPlainText(''), '');
  });

  test('collapses excessive blank lines', () {
    const html = '<p>A</p><p></p><p></p><p>B</p>';
    final text = htmlToPlainText(html);
    expect(text.contains('\n\n\n'), isFalse);
  });
}
