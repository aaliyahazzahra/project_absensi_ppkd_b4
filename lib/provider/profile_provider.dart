import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/models/response/profile_response.dart'
    as profile;
import 'package:project_absensi_ppkd_b4/repositories/profile_repository.dart';

class ProfileProvider with ChangeNotifier {
  ProfileRepository? _repository;

  ProfileProvider();

  void updateRepository(ProfileRepository repository) {
    _repository = repository;
  }

  // --- State Variables ---
  bool _isLoading = false;
  profile.Data? _userProfile;
  String? _errorMessage;

  // --- State Variables (Update Profile) ---
  bool _isUpdating = false;
  String? _updateErrorMessage;

  // --- State Variables (Logout) ---
  bool _isLoggingOut = false; // NEW
  String? _logoutErrorMessage; // NEW

  // --- Getters (agar UI bisa "membaca" state) ---
  bool get isLoading => _isLoading;
  profile.Data? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isUpdating => _isUpdating;
  String? get updateErrorMessage => _updateErrorMessage;
  bool get isLoggingOut => _isLoggingOut;
  String? get logoutErrorMessage => _logoutErrorMessage;

  // --- Logic Function ---
  Future<void> fetchProfileData() async {
    if (_repository == null) {
      _errorMessage = "Service not ready";
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 1. Set state ke loading
    _isLoading = true;
    _errorMessage = null;

    try {
      // 2. Panggil REPOSITORY, bukan ApiService
      final data = await _repository!.fetchProfile();
      _userProfile = data;
    } catch (e) {
      // 3. Tangani error
      _errorMessage = e.toString();
    } finally {
      // 4. Set loading selesai
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mencoba update profil dan mengembalikan `true` jika sukses.
  Future<bool> handleUpdateProfile({
    required String name,
    required String email,
  }) async {
    if (_repository == null) {
      _updateErrorMessage = "Service not ready";
      _isUpdating = false;
      notifyListeners();
      return false;
    }

    // 1. Set state ke loading
    _isUpdating = true;
    _updateErrorMessage = null;
    notifyListeners();

    try {
      // 2. Panggil REPOSITORY
      final updatedData = await _repository!.updateProfile(
        name: name,
        email: email,
      );

      // 3. JIKA SUKSES:
      _userProfile = updatedData;

      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      // 4. JIKA GAGAL:
      _updateErrorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false; // Kembalikan false (gagal)
    }
  }

  Future<bool> handleLogout() async {
    if (_repository == null) {
      _logoutErrorMessage = "Service not ready.";
      notifyListeners();
      return false;
    }

    _isLoggingOut = true;
    _logoutErrorMessage = null;
    notifyListeners();

    try {
      await _repository!.logout();

      _userProfile = null;

      _isLoggingOut = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logoutErrorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoggingOut = false;
      notifyListeners();
      return false;
    }
  }
}
