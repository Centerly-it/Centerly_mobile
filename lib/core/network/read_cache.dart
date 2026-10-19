import 'dart:convert';

/// Short-lived memory only. Never persists student or financial data to disk.
class ReadCache {
  ReadCache({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  final _entries = <String, (DateTime, String)>{};
  int generation = 0;

  void clear() {
    generation++;
    _entries.clear();
  }

  Object? get(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_now().difference(entry.$1) >= const Duration(seconds: 30)) {
      _entries.remove(key);
      return null;
    }
    return jsonDecode(entry.$2);
  }

  void put(String key, Object? value) {
    if (_entries.length >= 64) _entries.remove(_entries.keys.first);
    _entries[key] = (_now(), jsonEncode(value));
  }
}
