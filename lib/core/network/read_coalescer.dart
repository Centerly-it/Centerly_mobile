import 'dart:async';

/// Shares only active requests; response JSON is decoded separately per caller.
class ReadCoalescer {
  final _pending = <String, Future<String>>{};
  void clear() => _pending.clear();
  Future<String> run(String key, Future<String> Function() load) async {
    final current = _pending[key];
    if (current != null) return current;
    final operation = Future<String>.sync(load);
    // Do not retain an unbounded number of distinct concurrent requests.
    if (_pending.length < 64) _pending[key] = operation;
    try {
      return await operation;
    } finally {
      if (identical(_pending[key], operation)) unawaited(_pending.remove(key));
    }
  }
}
