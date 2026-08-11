import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/voice_clone/ai_server_manager.dart';

void main() {
  // Catches anything that slips past a call site's own error handling
  // (e.g. a native plugin/platform-channel failure) so it's logged instead
  // of tearing down the whole desktop process.
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('Uncaught Flutter error: ${details.exceptionAsString()}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught platform error: $error\n$stack');
      return true;
    };

    final aiServerManager = AiServerManager();
    unawaited(aiServerManager.start());
    late final AppLifecycleListener lifecycleListener;
    lifecycleListener = AppLifecycleListener(
      onExitRequested: () async {
        aiServerManager.stop();
        lifecycleListener.dispose();
        return AppExitResponse.exit;
      },
    );

    runApp(const ProviderScope(child: EchoBookApp()));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}
