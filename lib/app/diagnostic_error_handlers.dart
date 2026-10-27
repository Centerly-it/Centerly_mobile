import 'package:flutter/foundation.dart';
import '../core/diagnostics/app_diagnostics.dart';

void installDiagnosticErrorHandlers() {
  FlutterError.onError = (details) {
    AppDiagnostics.current.failure(
      'flutter.framework',
      'UNHANDLED_ERROR',
      details.stack,
      details.exception,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppDiagnostics.current.failure(
      'dart.unhandled',
      'UNHANDLED_ERROR',
      stack,
      error,
    );
    return true;
  };
}
