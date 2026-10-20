import 'dart:convert';

class AppConfig {
  const AppConfig({
    required this.url,
    required this.publishableKey,
    this.supportUrl = '',
    this.environment = 'development',
  });
  factory AppConfig.fromEnvironment() => const AppConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    publishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    supportUrl: String.fromEnvironment('CENTERLY_SUPPORT_URL'),
    environment: String.fromEnvironment('APP_ENV', defaultValue: 'development'),
  );
  final String url, publishableKey, supportUrl, environment;
  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
  bool get isValid {
    final uri = Uri.tryParse(url);
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
    final uri = Uri.tryParse(
      supportUrl.isEmpty ? 'https://wa.me/201028684980' : supportUrl,
    );
    return uri != null &&
            ['https', 'tel', 'mailto'].contains(uri.scheme) &&
            (uri.scheme != 'https' || uri.host.isNotEmpty)
        ? uri
        : null;
  }
}
