import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/profile_response.dart'
    as profile;
import 'package:project_absensi_ppkd_b4/data/repositories/profile_repository.dart';

class ProfileProvider with ChangeNotifier {
  ProfileRepository? _repository;

  ProfileProvider();

  void updateRepository(ProfileRepository repository) {
    _repository = repository;
  }

  bool _isLoading = false;
  profile.Data? _userProfile;
  String? _errorMessage;

  bool _isUpdating = false;
  String? _updateErrorMessage;

  bool _isLoggingOut = false;
  String? _logoutErrorMessage;

  bool _isUploadingPhoto = false;
  String? _uploadPhotoErrorMessage;

  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get uploadPhotoErrorMessage => _uploadPhotoErrorMessage;

  bool get isLoading => _isLoading;
  profile.Data? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isUpdating => _isUpdating;
  String? get updateErrorMessage => _updateErrorMessage;
  bool get isLoggingOut => _isLoggingOut;
  String? get logoutErrorMessage => _logoutErrorMessage;

  Future<void> fetchProfileData() async {
    if (_repository == null) {
      _errorMessage = "Service not ready";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    try {
      final data = await _repository!.fetchProfile();
      _userProfile = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

    _isUpdating = true;
    _updateErrorMessage = null;
    notifyListeners();

    try {
      final currentPhoto = _userProfile?.profilePhoto;
      final updatedData = await _repository!.updateProfile(
        name: name,
        email: email,
        profilePhoto: currentPhoto,
      );

      _userProfile = updatedData;

      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateErrorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
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

  Future<bool> handleUploadProfilePhoto(File imageFile) async {
    if (_repository == null) {
      _uploadPhotoErrorMessage = "Service not ready";
      notifyListeners();
      return false;
    }

    _isUploadingPhoto = true;
    _uploadPhotoErrorMessage = null;
    notifyListeners();

    try {
      final newPhotoUrl = await _repository!.uploadProfilePhoto(imageFile);

      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(profilePhoto: newPhotoUrl);
      }

      _isUploadingPhoto = false;
      notifyListeners();
      return true;
    } catch (e) {
      _uploadPhotoErrorMessage = e.toString().replaceAll("Exception: ", "");
      _isUploadingPhoto = false;
      notifyListeners();
      return false;
    }
  }
}
