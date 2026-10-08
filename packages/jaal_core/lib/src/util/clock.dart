import 'dart:async';

/// Wall-clock source, injectable so the simulator can run in virtual time.
abstract interface class Clock {
  int nowMs();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  int nowMs() => DateTime.now().millisecondsSinceEpoch;
}

/// Manually advanced clock for tests and the simulator.
class ManualClock implements Clock {
  ManualClock([this._now = 1767225600000]); // 2026-01-01T00:00:00Z

  int _now;

  @override
  int nowMs() => _now;

  void advance(Duration d) => _now += d.inMilliseconds;
  set now(int ms) => _now = ms;
}

/// Minimal async mutex: serializes critical sections in one isolate.
class Mutex {
  Future<void> _last = Future.value();

  Future<T> run<T>(Future<T> Function() body) {
    final prev = _last;
    final done = Completer<void>();
    _last = done.future;
    return prev.then((_) => body()).whenComplete(done.complete);
  }
}
