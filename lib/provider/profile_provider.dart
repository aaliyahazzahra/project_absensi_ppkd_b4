import 'package:flutter/material.dart';
// Import model 'Data' dari profile_response dengan aliasnya
import 'package:project_absensi_ppkd_b4/models/response/profile_response.dart'
    as profile;
import 'package:project_absensi_ppkd_b4/repositories/profile_repository.dart';

// 1. Gunakan 'ChangeNotifier' untuk memberi tahu UI jika ada perubahan state
class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({required ProfileRepository repository})
    : _repository = repository;

  // --- State Variables ---
  bool _isLoading = false;
  profile.Data? _userProfile;
  String? _errorMessage;

  // --- Getters (agar UI bisa "membaca" state) ---
  bool get isLoading => _isLoading;
  profile.Data? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;

  // --- Logic Function ---
  Future<void> fetchProfileData() async {
    // 1. Set state ke loading
    _isLoading = true;
    _errorMessage = null; // Hapus error lama
    notifyListeners(); // Beri tahu UI "Halo, saya lagi loading!"

    try {
      // 2. Panggil REPOSITORY, bukan ApiService
      final data = await _repository.fetchProfile();
      _userProfile = data;
    } catch (e) {
      // 3. Tangani error
      _errorMessage = e.toString();
    } finally {
      // 4. Set loading selesai
      _isLoading = false;
      notifyListeners(); // Beri tahu UI "Halo, saya sudah selesai!"
    }
  }
}
