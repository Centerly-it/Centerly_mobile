import 'package:sentry_flutter/sentry_flutter.dart';
import 'diagnostic_http_client.dart';
import 'diagnostic_response.dart';
import 'diagnostic_error_type.dart';

SentryEvent? sanitizedDiagnosticEvent(SentryEvent event) {
  if (event.tags?['centerly_safe'] != 'true') return null;
  const keys = {
    'operation',
    'outcome',
    'request_id',
    'status',
    'elapsed_ms',
    'response_bytes',
    'code',
    'response_shape',
    'source',
    'error_type',
  };
  final tags = <String, String>{};
  for (final entry in (event.tags ?? <String, String>{}).entries) {
    if (!keys.contains(entry.key) || entry.value.length > 200) continue;
    if (entry.key == 'operation') {
      final value = entry.value;
      const local = {
        'app.bootstrap',
        'app.config',
        'flutter.framework',
        'dart.unhandled',
        'bloc.error',
        'support.contact',
        'app.update',
      };
      final parts = value.split(' ');
      final http =
          parts.length == 2 &&
          {
            'GET',
            'POST',
            'PUT',
            'PATCH',
            'DELETE',
            'HEAD',
            'OTHER',
          }.contains(parts[0]) &&
          diagnosticEndpoint(Uri(path: parts[1])) == parts[1];
      if (!local.contains(value) && !http) continue;
    } else if (entry.key == 'code') {
      if (!{
        ...diagnosticErrorCodes,
        'TRANSPORT_ERROR',
        'UNHANDLED_ERROR',
        'CONFIG_INVALID',
        'SUPPORT_UNAVAILABLE',
        'UPDATE_CHECK_FAILED',
        'UPDATE_SPACE',
        'UPDATE_CHECKSUM',
        'UPDATE_SIGNATURE',
        'UPDATE_INCOMPATIBLE',
        'UPDATE_PERMISSION',
        'UPDATE_NETWORK',
      }.contains(entry.value)) {
        continue;
      }
    } else if (entry.key == 'error_type') {
      if (!diagnosticErrorTypes.contains(entry.value)) continue;
    } else if (entry.key == 'source') {
      if (!RegExp(
        r'^package:centrally/[a-zA-Z0-9_/]+\.dart:\d+:\d+$',
      ).hasMatch(entry.value)) {
        continue;
      }
    } else if (!RegExp(r'^[a-zA-Z0-9_:]+$').hasMatch(entry.value)) {
      continue;
    }
    tags[entry.key] = entry.value;
  }
  return SentryEvent(
    eventId: event.eventId,
    timestamp: event.timestamp,
    message: SentryMessage('Centerly diagnostic'),
    level: SentryLevel.error,
    environment: 'production',
    tags: tags,
  );
}
