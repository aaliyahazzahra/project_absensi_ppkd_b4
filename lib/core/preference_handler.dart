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
    await saveLoginStatus(true);
  }

  // --- GET DATA ---
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // --- REMOVE DATA (Logout Function) ---
  // Ganti nama fungsi menjadi clearAllAuthData agar lebih mencerminkan aksi
  static Future<void> clearAllAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    // PERBAIKAN: Hapus kedua key secara terpisah dan benar
    await prefs.remove(_isLoginKey);
    await prefs.remove(_tokenKey);
  }
}
