import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'diagnostic_record.dart';
import 'diagnostic_error_type.dart';
export 'diagnostic_record.dart';

/// Bounded metadata only. No tokens, request/response values or raw exceptions.
class AppDiagnostics {
  AppDiagnostics({
    required this.environment,
    required this.console,
    this.report,
  });
  static AppDiagnostics current = AppDiagnostics(
    environment: const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    ),
    console:
        kDebugMode &&
        const String.fromEnvironment('APP_ENV', defaultValue: 'development') ==
            'development',
  );
  final String environment;
  final bool console;
  final void Function(DiagnosticRecord)? report;
  final _recent = ListQueue<DiagnosticRecord>();
  List<DiagnosticRecord> get recent => List.unmodifiable(_recent);
  int _sequence = 0;
  String nextRequestId() => 'r${++_sequence}';
  void failure(
    String operation,
    String code, [
    StackTrace? stack,
    Object? error,
  ]) {
    final frame = stack == null
        ? null
        : RegExp(
            r'package:centrally/[a-zA-Z0-9_/]+\.dart:\d+:\d+',
          ).firstMatch(stack.toString())?.group(0);
    record(
      DiagnosticRecord(
        operation: operation,
        outcome: 'failed',
        code: code,
        source: frame,
        errorType: diagnosticErrorType(error),
      ),
    );
  }

  void record(DiagnosticRecord event) {
    if (!console && !event.failure) return;
    if (_recent.length == 50) _recent.removeFirst();
    _recent.addLast(event);
    if (console && kDebugMode && environment == 'development') {
      debugPrint('[Centerly][$environment] ${jsonEncode(event.toJson())}');
    }
    if (event.failure) {
      try {
        report?.call(event);
      } catch (_) {
        /* Diagnostics cannot break work. */
      }
    }
  }
}
