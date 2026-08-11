import 'package:echobook/features/tts_player/providers/sleep_timer_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ticks once a second, reporting decreasing remaining time', () {
    fakeAsync((async) {
      final controller = SleepTimerController();
      final ticks = <Duration>[];

      controller.start(
        const Duration(seconds: 3),
        onTick: ticks.add,
        onExpire: () => fail('should not expire before 3 seconds pass'),
      );

      // start() reports the initial duration synchronously.
      expect(ticks, [const Duration(seconds: 3)]);

      async.elapse(const Duration(seconds: 1));
      expect(ticks.last, const Duration(seconds: 2));

      async.elapse(const Duration(seconds: 1));
      expect(ticks.last, const Duration(seconds: 1));

      controller.dispose();
    });
  });

  test('calls onExpire exactly once when the countdown reaches zero', () {
    fakeAsync((async) {
      final controller = SleepTimerController();
      var expireCount = 0;

      controller.start(
        const Duration(seconds: 2),
        onTick: (_) {},
        onExpire: () => expireCount++,
      );

      async.elapse(const Duration(seconds: 2));
      expect(expireCount, 1);

      // The internal timer is cancelled on expiry, so further elapsed
      // time must not fire onExpire again.
      async.elapse(const Duration(seconds: 5));
      expect(expireCount, 1);
    });
  });

  test('cancel() stops ticking and clears remaining without calling onExpire', () {
    fakeAsync((async) {
      final controller = SleepTimerController();
      var expireCount = 0;

      controller.start(const Duration(seconds: 10), onTick: (_) {}, onExpire: () => expireCount++);
      async.elapse(const Duration(seconds: 3));
      controller.cancel();

      expect(controller.remaining, isNull);

      async.elapse(const Duration(seconds: 20));
      expect(expireCount, 0);
    });
  });

  test('start() while already running replaces the previous countdown', () {
    fakeAsync((async) {
      final controller = SleepTimerController();
      final ticks = <Duration>[];

      controller.start(const Duration(seconds: 30), onTick: ticks.add, onExpire: () {});
      async.elapse(const Duration(seconds: 1));

      controller.start(const Duration(minutes: 5), onTick: ticks.add, onExpire: () {});
      expect(controller.remaining, const Duration(minutes: 5));

      controller.dispose();
    });
  });
}
