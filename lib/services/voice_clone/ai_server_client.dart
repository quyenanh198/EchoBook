import 'dart:convert';

import 'package:http/http.dart' as http;

class AiServerException implements Exception {
  final String message;
  const AiServerException(this.message);

  @override
  String toString() => message;
}

/// Thin HTTP client for the local Python AI Server (`ai_server/`,
/// Windows-only for now — see `AiServerManager`) that performs the heavy
/// lifting for real voice cloning: extracting a speaker embedding from a
/// recorded sample with a pretrained encoder and saving it as a portable
/// `.echovoice` file. EchoBook itself never loads that model — only this
/// client, talking to the server on localhost.
class AiServerClient {
  final String baseUrl;
  final Duration healthCheckTimeout;
  final Duration cloneTimeout;

  const AiServerClient({
    this.baseUrl = 'http://127.0.0.1:8722',
    this.healthCheckTimeout = const Duration(seconds: 3),
    this.cloneTimeout = const Duration(seconds: 60),
  });

  Future<bool> isHealthy() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(healthCheckTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Uploads the WAV recording at [sampleWavPath], asks the server to
  /// extract a speaker embedding from it, and returns the path (on the
  /// server's own machine — always localhost here) of the saved
  /// `.echovoice` file.
  Future<String> cloneVoice({required String name, required String sampleWavPath}) async {
    final uri = Uri.parse('$baseUrl/voice/clone');
    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..files.add(await http.MultipartFile.fromPath('sample', sampleWavPath));

    final http.Response response;
    try {
      // Timing out `.send()` alone only bounds how long headers take to
      // arrive — a stall while the body streams in afterward would hang
      // this indefinitely otherwise. One timeout around the whole
      // send-then-read sequence bounds the entire call to cloneTimeout.
      response = await Future(() async {
        final streamedResponse = await request.send();
        return http.Response.fromStream(streamedResponse);
      }).timeout(cloneTimeout);
    } catch (e) {
      throw AiServerException('Could not reach the AI Server: $e');
    }
    if (response.statusCode != 200) {
      throw AiServerException('AI Server returned ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final path = body['path'] as String?;
    if (path == null) {
      throw AiServerException('AI Server response was missing the saved .echovoice path.');
    }
    return path;
  }
}
