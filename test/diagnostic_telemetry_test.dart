import 'package:centrally/core/diagnostics/diagnostic_event_sanitizer.dart';
import 'package:centrally/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test(
    'production event strips exceptions, users, requests and arbitrary tags',
    () {
      final event = SentryEvent(
        message: SentryMessage('private-password'),
        throwable: Exception('private-student'),
        user: SentryUser(email: 'private-email'),
        request: SentryRequest(url: 'https://host/private-token'),
        tags: {
          'centerly_safe': 'true',
          'operation': 'POST /rest/v1/rpc/get_current_profile',
          'code': 'SUBSCRIPTION_INACTIVE',
          'student': 'private-student',
          'source': '/Users/private-user/file.dart:3',
        },
      );
      final safe = sanitizedDiagnosticEvent(event)!;
      expect(safe.message!.formatted, 'Centerly diagnostic');
      expect(safe.user, isNull);
      expect(safe.request, isNull);
      expect(safe.throwable, isNull);
      expect(safe.tags, {
        'operation': 'POST /rest/v1/rpc/get_current_profile',
        'code': 'SUBSCRIPTION_INACTIVE',
      });
      expect(safe.contexts.toJson(), isEmpty);
      expect(
        sanitizedDiagnosticEvent(SentryEvent(throwable: Exception('raw'))),
        isNull,
      );
    },
  );
  test('flavor and backend environment cannot be swapped', () {
    expect(AppConfig.matchesFlavor('dev', 'development'), isTrue);
    expect(AppConfig.matchesFlavor('prod', 'production'), isTrue);
    expect(AppConfig.matchesFlavor('dev', 'production'), isFalse);
    expect(AppConfig.matchesFlavor('prod', 'development'), isFalse);
    expect(AppConfig.matchesFlavor('unexpected', 'production'), isFalse);
    expect(AppConfig.matchesFlavor(null, 'development'), isTrue);
  });
}
