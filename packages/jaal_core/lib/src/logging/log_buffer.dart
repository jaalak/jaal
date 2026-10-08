import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';

/// Captures log records in a bounded ring buffer for in-app debug tools
/// (Network Lab "wire log") and the simulator CLI.
class LogBuffer {
  LogBuffer({this.capacity = 2000});

  final int capacity;
  final _records = ListQueue<LogRecord>();
  final _controller = StreamController<LogRecord>.broadcast();
  StreamSubscription<LogRecord>? _sub;

  List<LogRecord> get records => List.unmodifiable(_records);
  Stream<LogRecord> get stream => _controller.stream;

  /// Starts capturing from the root logger at [level].
  void attach({Level level = Level.INFO}) {
    hierarchicalLoggingEnabled = true;
    Logger.root.level = level;
    _sub ??= Logger.root.onRecord.listen(_add);
  }

  void _add(LogRecord r) {
    _records.addLast(r);
    while (_records.length > capacity) {
      _records.removeFirst();
    }
    _controller.add(r);
  }

  void clear() => _records.clear();

  Future<void> detach() async {
    await _sub?.cancel();
    _sub = null;
  }

  static String format(LogRecord r) =>
      '${r.time.toIso8601String().substring(11, 23)} '
      '${r.level.name.padRight(7)} ${r.loggerName}: ${r.message}';
}
