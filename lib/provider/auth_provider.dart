import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool _isLoading = false; // Untuk login
  String? _errorMessage; // Error login
  bool _isLoggedIn = false; // Penanda sukses login
  bool _isRegisterLoading = false; // Untuk register
  String? _registerErrorMessage; // Error register

  bool get isLoading => _isLoading;
  bool get isRegisterLoading => _isRegisterLoading;
  String? get errorMessage => _errorMessage;
  String? get registerErrorMessage => _registerErrorMessage;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> handleLogin(String email, String password) async {
    // 1. Set state ke loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. Panggil REPOSITORY
      await _repository.login(email, password);

      // 3. Jika sukses
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // 4. Jika gagal (misal password salah)
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
    // 1. Set state ke loading
    _isRegisterLoading = true;
    _registerErrorMessage = null;
    notifyListeners();

    try {
      // 2. Panggil REPOSITORY
      await _repository.register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        profilePhoto: profilePhoto,
        batchId: batchId,
        trainingId: trainingId,
      );

      // 3. Jika sukses
      _isLoggedIn = true;
      _isRegisterLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // 4. Jika gagal
      _registerErrorMessage = e.toString();
      _isLoggedIn = false;
      _isRegisterLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> handleLogout() async {
    try {
      await _repository.logout();
    } catch (e) {
      print("Error during logout: $e");
    } finally {
      _isLoggedIn = false;
      notifyListeners();
    }
  }
}
