import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  AuthRepository? _repository; // 1. Buat jadi nullable

  // 2. Kosongkan constructor (tidak perlu 'required repository' lagi)
  AuthProvider();

  // 3. Buat fungsi untuk "menyuntik" repository nanti
  void updateRepository(AuthRepository repository) {
    _repository = repository;
  }

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  bool _isRegisterLoading = false;
  String? _registerErrorMessage;

  bool get isLoading => _isLoading;
  bool get isRegisterLoading => _isRegisterLoading;
  String? get errorMessage => _errorMessage;
  String? get registerErrorMessage => _registerErrorMessage;
  bool get isLoggedIn => _isLoggedIn;

  // 4. Tambahkan null check di semua fungsi yang memakai _repository
  Future<bool> handleLogin(String email, String password) async {
    // Tambahkan Pengecekan
    if (_repository == null) {
      _errorMessage = "Service not ready";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository!.login(email, password); // Gunakan '!'
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleRegister({
    required String name,
    required String email,
    required String password,
    required String? jenisKelamin,
    required String profilePhoto,
    required int? batchId,
    required int? trainingId,
  }) async {
    // Tambahkan Pengecekan
    if (_repository == null) {
      _registerErrorMessage = "Service not ready";
      notifyListeners();
      return false;
    }

    _isRegisterLoading = true;
    _registerErrorMessage = null;
    notifyListeners();

    try {
      await _repository!.register(
        // Gunakan '!'
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        profilePhoto: profilePhoto,
        batchId: batchId,
        trainingId: trainingId,
      );
      _isLoggedIn = true;
      _isRegisterLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _registerErrorMessage = e.toString();
      _isLoggedIn = false;
      _isRegisterLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> handleLogout() async {
    // Tambahkan Pengecekan
    if (_repository == null) {
      print("Logout failed: repository is null");
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    try {
      await _repository!.logout(); // Gunakan '!'
    } catch (e) {
      print("Error during logout: $e");
    } finally {
      _isLoggedIn = false;
      notifyListeners();
    }
  }
}
