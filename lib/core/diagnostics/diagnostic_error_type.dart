const diagnosticErrorTypes = {
  'FormatException',
  'StateError',
  'TypeError',
  'TimeoutException',
  'ClientException',
  'SocketException',
  'PlatformException',
  'PostgrestException',
  'AuthException',
  'AuthApiException',
  'AuthRetryableFetchException',
  'FlutterError',
  'Other',
};

String? diagnosticErrorType(Object? error) {
  if (error == null) return null;
  final name = error.runtimeType.toString();
  return diagnosticErrorTypes.contains(name) ? name : 'Other';
}
