import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';
  static const String _languageKey = 'app_language';

  LocalStorageService(this._prefs);

  // Token Management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User Data
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(_userKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(_userKey);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
  }

  // Role Management
  Future<void> saveRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  String? getRole() {
    return _prefs.getString(_roleKey);
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'ar';
  }

  // Clear All
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if logged in
  bool isLoggedIn() {
    return _prefs.getString(_tokenKey) != null;
  }
}
