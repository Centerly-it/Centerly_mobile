import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureAuthStorage extends LocalStorage {
  const SecureAuthStorage(
    this.key, {
    this.storage = const FlutterSecureStorage(),
  });
  final String key;
  final FlutterSecureStorage storage;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => await storage.containsKey(key: key);
  @override
  Future<String?> accessToken() => storage.read(key: key);
  @override
  Future<void> persistSession(String persistSessionString) =>
      storage.write(key: key, value: persistSessionString);
  @override
  Future<void> removePersistedSession() => storage.delete(key: key);
}
