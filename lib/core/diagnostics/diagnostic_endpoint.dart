import 'diagnostic_routes.dart';

String diagnosticEndpoint(Uri uri) {
  final p = uri.pathSegments;
  if (p.length == 4 &&
      p.take(3).join('/') == 'rest/v1/rpc' &&
      diagnosticRpcNames.contains(p.last)) {
    return '/rest/v1/rpc/${p.last}';
  }
  const auth = {'token', 'logout', 'user', 'settings'};
  if (p.length == 3 &&
      p.take(2).join('/') == 'auth/v1' &&
      auth.contains(p.last)) {
    return '/auth/v1/${p.last}';
  }
  const tables = {
    'teachers',
    'students',
    'groups',
    'secretaries',
    'notifications',
  };
  if (p.length == 3 &&
      p.take(2).join('/') == 'rest/v1' &&
      tables.contains(p.last)) {
    return '/rest/v1/${p.last}';
  }
  return '/redacted-endpoint';
}
