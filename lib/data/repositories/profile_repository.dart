import 'dart:io';

import 'package:project_absensi_ppkd_b4/data/models/response/profile_response.dart'
    as profile;
import 'package:project_absensi_ppkd_b4/data/service/api_service.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository({required ApiService apiService})
    : _apiService = apiService;

  Future<profile.Data> fetchProfile() async {
    try {
      final profileData = await _apiService.getProfile();
      return profileData;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<profile.Data> updateProfile({
    required String name,
    required String email,
    required String? profilePhoto,
  }) async {
    try {
      final updatedProfileData = await _apiService.updateProfile(
        name: name,
        email: email,
        profilePhoto: profilePhoto,
      );
      return updatedProfileData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final photoUrl = await _apiService.uploadProfilePhoto(imageFile);
      return photoUrl;
    } catch (e) {
      rethrow;
    }
  }
}
