import 'dart:io';

import 'package:echobook/services/voice_clone/ai_server_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiServerClient against an unreachable server', () {
    // No server listens on this port in the test environment — every call
    // should degrade gracefully (false / a typed exception), never hang
    // or throw an unhandled error, since VoiceCloneService treats "server
    // not running" as the normal, expected case on any non-Windows
    // platform (and on Windows before the AI Server has started).
    const client = AiServerClient(
      baseUrl: 'http://127.0.0.1:1',
      healthCheckTimeout: Duration(seconds: 2),
      cloneTimeout: Duration(seconds: 2),
    );

    test('isHealthy() returns false instead of throwing', () async {
      expect(await client.isHealthy(), isFalse);
    });

    test('cloneVoice() throws AiServerException instead of an unhandled error', () async {
      final tempFile = await File(
        '${Directory.systemTemp.path}/ai_server_client_test_sample.wav',
      ).create();
      await tempFile.writeAsBytes(List.filled(100, 0));
      addTearDown(() => tempFile.delete());

      expect(
        () => client.cloneVoice(name: 'x', sampleWavPath: tempFile.path),
        throwsA(isA<AiServerException>()),
      );
    });
  });
}
