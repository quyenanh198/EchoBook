import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where recorded/uploaded voice samples for cloned profiles are stored.
class VoicePaths {
  static Future<String> newSamplePath(String profileId, {String extension = 'wav'}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'voices'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return p.join(dir.path, '$profileId.$extension');
  }
}
