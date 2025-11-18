import 'package:project_absensi_ppkd_b4/models/response/auth_response.dart'
    as auth;
import 'package:project_absensi_ppkd_b4/service/api_service.dart';

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

  Future<auth.Data> register({
    required String name,
    required String email,
    required String password,
    required String? jenisKelamin,
    required String profilePhoto, // base64 string
    required int? batchId,
    required int? trainingId,
  }) async {
    try {
      // 1. Panggil ApiService
      final authData = await _apiService.register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        profilePhoto: profilePhoto,
        batchId: batchId,
        trainingId: trainingId,
      );

      // 2. Sama seperti login, data dikembalikan ke provider
      return authData;
    } catch (e) {
      // Teruskan error (misal "Email sudah terdaftar") ke Provider
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Panggil fungsi logout dari ApiService
      await _apiService.logout();
    } catch (e) {
      rethrow;
    }
  }
}
