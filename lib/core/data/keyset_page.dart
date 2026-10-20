/// PostgreSQL UUID cursors use canonical lexical order. Reject a looping page.
String? validateKeysetPage(
  Iterable<String> values, {
  required int limit,
  String? cursor,
}) {
  final ids = values.toList(growable: false);
  if (ids.length > limit) throw const FormatException('Oversized page');
  String? previous = cursor;
  for (final id in ids) {
    if (id.isEmpty || (previous != null && id.compareTo(previous) <= 0)) {
      throw const FormatException('Invalid keyset order');
    }
    previous = id;
  }
  return ids.length == limit ? ids.last : null;
}
