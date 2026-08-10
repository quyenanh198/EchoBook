import 'package:flutter/material.dart';

/// Global [ScaffoldMessengerState] key so non-widget classes (like
/// `PlayerController`) can surface a dismissible error message without
/// needing a [BuildContext].
///
/// This exists so a native TTS/engine failure (missing plugin, missing
/// system voice, microphone unavailable, etc.) becomes a visible, recoverable
/// SnackBar instead of an exception with nowhere to go — which is what was
/// taking the whole app down before these call sites had anywhere to report
/// failures other than throwing.
class AppMessenger {
  static final key = GlobalKey<ScaffoldMessengerState>();

  static void showError(String message) {
    key.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }
}
