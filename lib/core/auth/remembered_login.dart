import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Device-only remembered login, isolated from other backend environments.
class RememberedLogin {
  const RememberedLogin(this.environmentUrl);
  final String environmentUrl;
  static const _storage = FlutterSecureStorage();
  String get _key => 'centerly-remembered-login-$environmentUrl';

  Future<({String email, String password})?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final value = jsonDecode(raw);
      if (value is! Map ||
          value['email'] is! String ||
          value['password'] is! String) {
        return null;
      }
      return (
        email: value['email'] as String,
        password: value['password'] as String,
      );
    } catch (_) {
      return null; // Credential convenience must not prevent signing in.
    }
  }

  Future<void> save(String email, String password) async {
    try {
      await _storage.write(
        key: _key,
        value: jsonEncode({'email': email.trim(), 'password': password}),
      );
    } catch (_) {
      // A successful authenticated session remains valid if storage is unavailable.
    }
  }
}
