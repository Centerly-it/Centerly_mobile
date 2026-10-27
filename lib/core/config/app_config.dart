import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'backend_projects.dart';

class AppConfig {
  static const defaultSupportUrl = 'https://wa.me/201028684980';
  const AppConfig({
    required this.url,
    required this.publishableKey,
    this.supportUrl = '',
    this.environment = 'development',
  });
  factory AppConfig.fromEnvironment() => const AppConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    publishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    supportUrl: String.fromEnvironment(
      'CENTERLY_SUPPORT_URL',
      defaultValue: defaultSupportUrl,
    ),
    environment: String.fromEnvironment('APP_ENV', defaultValue: 'development'),
  );
  final String url, publishableKey, supportUrl, environment;
  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
  bool get isValid {
    if (kReleaseMode && environment != 'production') return false;
    final uri = Uri.tryParse(url);
    if (uri != null && !BackendProjects.accepts(environment, uri.host)) {
      return false;
    }
    if (!['development', 'production'].contains(environment) ||
        (environment == 'production' && publishableKey.contains('fixture'))) {
      return false;
    }
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.scheme != 'https' &&
            !(environment == 'development' &&
                uri.scheme == 'http' &&
                ['localhost', '127.0.0.1'].contains(uri.host)))) {
      return false;
    }
    if (publishableKey.startsWith('sb_publishable_')) return true;
    // Legacy anon JWTs are public, but service-role JWTs must never enter Flutter.
    try {
      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(base64Url.normalize(publishableKey.split('.')[1])),
        ),
      );
      return payload is Map && payload['role'] == 'anon';
    } catch (_) {
      return false;
    }
  }

  Uri? get supportUri {
    final configured = supportUrl.trim();
    final uri = Uri.tryParse(
      configured.isEmpty ? defaultSupportUrl : configured,
    );
    return uri != null &&
            ['https', 'tel', 'mailto'].contains(uri.scheme) &&
            (uri.scheme != 'https' || uri.host.isNotEmpty)
        ? uri
        : null;
  }
}
