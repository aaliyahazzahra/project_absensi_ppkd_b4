// Import model 'Data' dari auth_response dengan aliasnya
import 'package:project_absensi_ppkd_b4/models/response/auth_response.dart'
    as auth;
import 'package:project_absensi_ppkd_b4/service/api.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  // Fungsi login
  Future<auth.Data> login(String email, String password) async {
    try {
      // 1. Panggil ApiService
      final authData = await _apiService.login(email, password);

      // 2. Di sinilah tempatnya jika Anda ingin menyimpan data
      //    user (authData.user) ke database lokal (SQLite/Hive)
      //    Tapi untuk sekarang, kita teruskan saja datanya.

      return authData;
    } catch (e) {
      // Teruskan error (misal "Password salah") ke Provider
      rethrow;
    }
  }

  // TODO: Tambahkan fungsi register di sini
  // Future<auth.Data> register(...) async { ... }

  // TODO: Tambahkan fungsi logout di sini
  // Future<void> logout() async { ... }
}
