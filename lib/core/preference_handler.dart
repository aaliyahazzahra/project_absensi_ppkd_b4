import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _isLoginKey = "isLogin";
  static const String _tokenKey = "isToken";

  // --- SAVE DATA ---
  static Future<void> saveLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoginKey, value);
  }

  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, value);
  }

  // --- GET DATA ---
  // Mengembalikan nilai boolean, default-nya false jika tidak ada data
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  // Mengembalikan nilai String, default-nya null jika tidak ada data
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // --- REMOVE DATA ---
  static Future<void> removeLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoginKey);
    // Tambahkan juga penghapusan token saat logout
    await prefs.remove(_tokenKey);
  }
}
