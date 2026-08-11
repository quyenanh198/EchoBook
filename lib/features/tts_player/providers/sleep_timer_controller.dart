import 'dart:async';

/// Countdown timer for Listen Mode's sleep timer.
///
/// Pure timer/countdown logic with no knowledge of [PlayerState] or the
/// voice engine — [PlayerController] wires [start]'s `onTick`/`onExpire`
/// callbacks into its own state updates and [PlayerController.stop].
/// Split out so player_providers.dart isn't the single place every
/// Listen Mode concern (playback, progress-save, sleep timer, error
/// handling) has to live in.
class SleepTimerController {
  Timer? _ticker;
  Duration? _remaining;

  Duration? get remaining => _remaining;

  /// Starts (or restarts) a [duration]-long countdown, calling [onTick]
  /// once a second with the remaining time and [onExpire] exactly once
  /// when it reaches zero. Cancels any timer already running first.
  void start(
    Duration duration, {
    required void Function(Duration remaining) onTick,
    required void Function() onExpire,
  }) {
    cancel();
    _remaining = duration;
    onTick(duration);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _remaining! - const Duration(seconds: 1);
      if (next.isNegative || next == Duration.zero) {
        cancel();
        onExpire();
      } else {
        _remaining = next;
        onTick(next);
      }
    });
  }

  /// Stops the countdown without firing [onExpire]. Safe to call whether
  /// or not a countdown is running.
  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    _remaining = null;
  }

  void dispose() => cancel();
}
