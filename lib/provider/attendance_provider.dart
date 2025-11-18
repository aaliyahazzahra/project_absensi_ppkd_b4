import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/models/response/today_status_response.dart';
import 'package:project_absensi_ppkd_b4/repositories/attendance_repository.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceRepository _repository;
  AttendanceProvider({required AttendanceRepository repository})
    : _repository = repository;

  bool _isLoadingStatus = false;
  TodayStatusData? _todayStatus;
  String? _statusErrorMessage;

  bool _isCheckingIn = false;
  String? _checkInErrorMessage;

  bool _isCheckingOut = false;
  String? _checkOutErrorMessage;

  bool get isLoadingStatus => _isLoadingStatus;
  TodayStatusData? get todayStatus => _todayStatus;
  String? get statusErrorMessage => _statusErrorMessage;

  bool get isCheckingIn => _isCheckingIn;
  String? get checkInErrorMessage => _checkInErrorMessage;

  bool get isCheckingOut => _isCheckingOut;
  String? get checkOutErrorMessage => _checkOutErrorMessage;

  Future<void> fetchTodayStatusData() async {
    _isLoadingStatus = true;
    _statusErrorMessage = null;

    try {
      _todayStatus = await _repository.fetchTodayStatus();
    } catch (e) {
      _statusErrorMessage = e.toString();
    } finally {
      _isLoadingStatus = false;
      notifyListeners();
    }
  }

  Future<bool> handleCheckIn({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    _isCheckingIn = true;
    _checkInErrorMessage = null;
    notifyListeners();

    try {
      // 1. Panggil REPOSITORY
      await _repository.checkIn(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      // 2. JIKA SUKSES:
      await fetchTodayStatusData();

      _isCheckingIn = false;
      notifyListeners(); // Beri tahu UI "Check-in selesai!"
      return true;
    } catch (e) {
      // 3. JIKA GAGAL:
      _checkInErrorMessage = e.toString();
      _isCheckingIn = false;
      notifyListeners(); // Beri tahu UI "Gagal check-in!"
      return false;
    }
  }

  Future<bool> handleCheckOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    _isCheckingOut = true;
    _checkOutErrorMessage = null;
    notifyListeners();

    try {
      // 1. Panggil REPOSITORY
      await _repository.checkOut(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      // 2. JIKA SUKSES:

      await fetchTodayStatusData();

      _isCheckingOut = false;
      notifyListeners(); // Beri tahu UI "Check-out selesai!"
      return true;
    } catch (e) {
      // 3. JIKA GAGAL:
      _checkOutErrorMessage = e.toString();
      _isCheckingOut = false;
      notifyListeners(); // Beri tahu UI "Gagal check-out!"
      return false;
    }
  }
}
