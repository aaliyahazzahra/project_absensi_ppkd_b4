import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  AuthRepository? _repository;

  bool _isLoadingOtp = false;
  String? _otpErrorMessage;
  String? _resetEmail;

  bool _isResettingPassword = false;
  String? _resetPasswordErrorMessage;

  AuthProvider();

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

  bool get isLoadingOtp => _isLoadingOtp;
  String? get otpErrorMessage => _otpErrorMessage;
  String? get resetEmail => _resetEmail;
  bool get isResettingPassword => _isResettingPassword;
  String? get resetPasswordErrorMessage => _resetPasswordErrorMessage;

  Future<bool> handleLogin(String email, String password) async {
    if (_repository == null) {
      _errorMessage = "Service not ready";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository!.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
    if (_repository == null) {
      print("Logout failed: repository is null");
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    try {
      await _repository!.logout();
    } catch (e) {
      print("Error during logout: $e");
    } finally {
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<bool> handleRequestOtp({required String email}) async {
    if (_repository == null) {
      _otpErrorMessage = "Service not ready.";
      notifyListeners();
      return false;
    }

    _isLoadingOtp = true;
    _otpErrorMessage = null;
    notifyListeners();

    try {
      await _repository!.requestOtp(email: email);

      _resetEmail = email;
      _isLoadingOtp = false;
      notifyListeners();
      return true;
    } catch (e) {
      _otpErrorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingOtp = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleResetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    if (_repository == null) {
      _resetPasswordErrorMessage = "Service not ready.";
      notifyListeners();
      return false;
    }

    _isResettingPassword = true;
    _resetPasswordErrorMessage = null;
    notifyListeners();

    try {
      await _repository!.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );

      _isResettingPassword = false;
      notifyListeners();
      return true;
    } catch (e) {
      _resetPasswordErrorMessage = e.toString().replaceAll("Exception: ", "");
      _isResettingPassword = false;
      notifyListeners();
      return false;
    }
  }
}
