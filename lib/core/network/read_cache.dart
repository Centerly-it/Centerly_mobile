import 'dart:convert';

/// Bounded, short-lived LRU. Sensitive records are never persisted to disk.
class ReadCache {
  ReadCache({
    DateTime Function()? now,
    this.maxEntries = 64,
    this.maxBytes = 2097152,
    this.maxEntryBytes = 262144,
  }) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  final int maxEntries, maxBytes, maxEntryBytes;
  final _entries =
      <String, ({DateTime at, Duration ttl, String json, int bytes})>{};
  int generation = 0, _bytes = 0;
  Object? _scope;
  void bind(Object scope) {
    if (_scope == null && _entries.isEmpty) {
      _scope = scope;
      return;
    }
    if (scope != _scope) {
      _scope = scope;
      clear();
    }
  }

  int get sizeBytes => _bytes;
  int get entryCount => _entries.length;
  void clear() {
    generation++;
    _entries.clear();
    _bytes = 0;
  }

  void _remove(String key) {
    final entry = _entries.remove(key);
    if (entry != null) _bytes -= entry.bytes;
  }

  Object? get(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    final age = _now().difference(entry.at);
    if (age.isNegative || age >= entry.ttl) {
      _remove(key);
      return null;
    }
    _entries.remove(key);
    _entries[key] = entry;
    return jsonDecode(entry.json);
  }

  void put(
    String key,
    Object? value, {
    Duration ttl = const Duration(seconds: 30),
  }) {
    _remove(key);
    if (ttl <= Duration.zero || maxEntries <= 0 || maxBytes <= 0) return;
    final json = jsonEncode(value);
    final bytes = utf8.encode(json).length;
    if (bytes > maxEntryBytes || bytes > maxBytes) return;
    while (_entries.isNotEmpty &&
        (_entries.length >= maxEntries || _bytes + bytes > maxBytes)) {
      _remove(_entries.keys.first);
    }
    _entries[key] = (at: _now(), ttl: ttl, json: json, bytes: bytes);
    _bytes += bytes;
  }
}
