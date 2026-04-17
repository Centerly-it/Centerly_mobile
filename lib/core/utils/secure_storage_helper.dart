import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  final FlutterSecureStorage _storage;

  SecureStorageHelper() : _storage = const FlutterSecureStorage();

  Future<void> saveData({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readData({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteData({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

class StorageKeys {
  static const String userToken = 'USER_TOKEN';
  static const String userId = 'USER_ID';
  static const String languageCode = 'LANGUAGE_CODE';
}
