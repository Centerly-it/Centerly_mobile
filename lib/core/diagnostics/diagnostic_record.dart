/// Strict metadata schema: callers cannot attach payloads, headers or messages.
class DiagnosticRecord {
  const DiagnosticRecord({
    required this.operation,
    required this.outcome,
    this.requestId,
    this.status,
    this.elapsedMs,
    this.bytes,
    this.code,
    this.shape,
    this.source,
    this.errorType,
  });
  final String operation, outcome;
  final String? requestId, code, shape, source, errorType;
  final int? status, elapsedMs, bytes;
  bool get failure => outcome == 'failed' || (status ?? 0) >= 400;
  Map<String, Object> toJson() => {
    'operation': operation,
    'outcome': outcome,
    'request_id': ?requestId,
    'status': ?status,
    'elapsed_ms': ?elapsedMs,
    'response_bytes': ?bytes,
    'code': ?code,
    'response_shape': ?shape,
    'source': ?source,
    'error_type': ?errorType,
  };
}
