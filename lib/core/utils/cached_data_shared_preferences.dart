import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();

  static late SharedPreferences _prefs;

  static Future<void> cacheInitialization() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setData({required String key, required dynamic value}) async {
    if (value is int) return _prefs.setInt(key, value);
    if (value is String) return _prefs.setString(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    return false;
  }

  static dynamic getData({required String key}) => _prefs.get(key);

  static Future<void> deleteItem({required String key}) => _prefs.remove(key);

  static Future<void> clearItems() => _prefs.clear();
}

class CacheConstants {
  CacheConstants._();

  static const String userToken = 'userToken';
  static const String role = 'role';
  static const String userEmail = 'userEmail';
  static const String userType = 'userType';
}
