import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app_diagnostics.dart';
import 'diagnostic_event_sanitizer.dart';

Future<void> initializeDiagnostics() async {
  const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  const dsn = String.fromEnvironment('CENTERLY_SENTRY_DSN');
  var enabled = false;
  if (environment == 'production' && dsn.isNotEmpty) {
    try {
      await Sentry.init((options) {
        options.dsn = dsn;
        options.environment = 'production';
        options.debug = false;
        options.sendDefaultPii = false;
        options.attachStacktrace = false;
        options.maxBreadcrumbs = 0;
        options.tracesSampleRate = 0;
        options.enableLogs = false;
        for (final integration in options.integrations.toList()) {
          options.removeIntegration(integration);
        }
        options.beforeSend = (event, hint) => sanitizedDiagnosticEvent(event);
      });
      enabled = true;
    } catch (_) {
      /* Missing/invalid telemetry never blocks login. */
    }
  }
  var sent = 0;
  var started = DateTime.now();
  AppDiagnostics.current = AppDiagnostics(
    environment: environment,
    console: kDebugMode && environment == 'development',
    report: enabled
        ? (record) {
            // Expected login/permission/business denials are not crash reports.
            if (record.status != null &&
                record.status! < 500 &&
                record.code != 'PGRST202' &&
                record.code != 'TRANSPORT_ERROR') {
              return;
            }
            // Bounded errors: no traffic/body tracing, attachments or session replay.
            if (DateTime.now().difference(started).inHours >= 1) {
              started = DateTime.now();
              sent = 0;
            }
            if (sent >= 20) return;
            sent++;
            unawaited(
              Sentry.captureEvent(
                SentryEvent(
                  message: SentryMessage('Centerly diagnostic'),
                  tags: {
                    'centerly_safe': 'true',
                    ...record.toJson().map((k, v) => MapEntry(k, v.toString())),
                  },
                ),
              ).then<void>((_) {}, onError: (Object _) {}),
            );
          }
        : null,
  );
}
