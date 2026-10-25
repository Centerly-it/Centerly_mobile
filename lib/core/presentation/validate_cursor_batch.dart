import '../errors/backend_failure.dart';

// Cursor values are opaque: endpoint adapters enforce their own ordering.
Set<String> validateCursorBatch(
  Iterable<String> ids,
  int received,
  String? next, {
  required String? requested,
  required Set<String> seen,
  required Set<String> loaded,
}) {
  final values = ids.toList(growable: false);
  final incoming = values.toSet();
  if (incoming.any(loaded.contains) ||
      values.any((id) => id.isEmpty) ||
      incoming.length != values.length ||
      (next != null &&
          (next.isEmpty ||
              received == 0 ||
              next == requested ||
              seen.contains(next)))) {
    throw const BackendFailure('SERVICE_UNAVAILABLE');
  }
  return incoming;
}
