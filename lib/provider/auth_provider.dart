import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  // --- State Variables ---
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false; // Penanda sukses login

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn; // Nanti UI akan 'listen' ke sini

  // --- Logic Function ---

  /// Mencoba login dan mengembalikan `true` jika sukses, `false` jika gagal.
  Future<bool> handleLogin(String email, String password) async {
    // 1. Set state ke loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beri tahu UI "Halo, saya lagi loading!"

    try {
      // 2. Panggil REPOSITORY
      await _repository.login(email, password);

      // 3. Jika sukses
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners(); // Beri tahu UI "Halo, login berhasil!"
      return true;
    } catch (e) {
      // 4. Jika gagal (misal password salah)
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners(); // Beri tahu UI "Halo, ada error!"
      return false;
    }
  }
}
