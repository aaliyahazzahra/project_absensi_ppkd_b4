import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/models/response/attendance_stats_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/history_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/today_status_response.dart';
import 'package:project_absensi_ppkd_b4/repositories/attendance_repository.dart';

class AttendanceProvider with ChangeNotifier {
  AttendanceRepository? _repository;

  AttendanceProvider();

  void updateRepository(AttendanceRepository repository) {
    _repository = repository;
  }

  // --- TODAY STATUS STATE ---
  bool _isLoadingStatus = false;
  TodayStatusData? _todayStatus;
  String? _statusErrorMessage;

  // --- CHECK IN/OUT STATE ---
  bool _isCheckingIn = false;
  String? _checkInErrorMessage;
  bool _isCheckingOut = false;
  String? _checkOutErrorMessage;

  // --- HISTORY STATE ---
  List<HistoryData>? _historyList;
  bool _isLoadingHistory = false;
  String? _historyErrorMessage;

  // --- STATS STATE ---
  AttendanceStatsData? _statsData;
  bool _isLoadingStats = false;
  String? _statsErrorMessage;
  String _totalWorkingHoursToday = "0h 0m";

  // --- GETTERS ---
  bool get isLoadingStatus => _isLoadingStatus;
  TodayStatusData? get todayStatus => _todayStatus;
  String? get statusErrorMessage => _statusErrorMessage;

  bool get isCheckingIn => _isCheckingIn;
  String? get checkInErrorMessage => _checkInErrorMessage;

  bool get isCheckingOut => _isCheckingOut;
  String? get checkOutErrorMessage => _checkOutErrorMessage;

  List<HistoryData>? get historyList => _historyList;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyErrorMessage => _historyErrorMessage;

  // GETTERS for Stats
  AttendanceStatsData? get statsData => _statsData;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsErrorMessage => _statsErrorMessage;
  String get totalWorkingHoursToday => _totalWorkingHoursToday;

  // Helper: Hitung Durasi Kerja (Input: HH:MM:SS)
  Duration _calculateWorkDuration(String? checkIn, String? checkOut) {
    if (checkIn == null || checkOut == null) return Duration.zero;

    try {
      final now = DateTime.now();
      // Gabungkan tanggal hari ini dengan waktu untuk membuat DateTime valid
      final checkInTime = DateTime.parse(
        '${now.toString().split(' ').first} $checkIn',
      );
      final checkOutTime = DateTime.parse(
        '${now.toString().split(' ').first} $checkOut',
      );

      // Hitung selisih
      if (checkOutTime.isAfter(checkInTime)) {
        return checkOutTime.difference(checkInTime);
      }
    } catch (e) {
      // Print error di console jika gagal parsing
      debugPrint('Error calculating duration: $e');
    }
    return Duration.zero;
  }

  // Helper: Format Durasi ke "Xh Ym"
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "0h 0m";
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  // Fungsi: Hitung jam kerja hari ini (Client-side)
  void _calculateTodayWorkingHours() {
    if (_todayStatus?.checkInTime != null &&
        _todayStatus?.checkOutTime != null) {
      final duration = _calculateWorkDuration(
        _todayStatus!.checkInTime,
        _todayStatus!.checkOutTime,
      );
      _totalWorkingHoursToday = _formatDuration(duration);
    } else {
      _totalWorkingHoursToday = "0h 0m";
    }
  }

  // Fungsi: Fetch Attendance Stats
  Future<void> fetchAttendanceStats({
    required String startDate,
    required String endDate,
  }) async {
    if (_repository == null) {
      _statsErrorMessage = "Service not ready";
      _isLoadingStats = false;
      notifyListeners();
      return;
    }

    _isLoadingStats = true;
    _statsErrorMessage = null;
    notifyListeners();

    try {
      _statsData = await _repository!.fetchAttendanceStats(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _statsErrorMessage = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodayStatusData() async {
    if (_repository == null) {
      _statusErrorMessage = "Service not ready";
      _isLoadingStatus = false;
      notifyListeners();
      return;
    }

    _isLoadingStatus = true;
    _statusErrorMessage = null;

    try {
      final response = await _repository!.fetchTodayStatus();

      // Cek apakah data valid. Jika null, _todayStatus diset null.
      _todayStatus = response;

      // Panggil perhitungan jam kerja (akan menjadi "0h 0m" jika _todayStatus null/belum checkout)
      _calculateTodayWorkingHours();
    } catch (e) {
      _statusErrorMessage = e.toString();
      // Penting: Jika ada error, set status menjadi null agar UI menunjukkan belum absen (kecuali error server)
      _todayStatus = null;
      _totalWorkingHoursToday = "0h 0m";
    } finally {
      _isLoadingStatus = false;
      notifyListeners(); // Memicu rebuild di Home Page
    }
  }

  Future<void> fetchAttendanceHistory() async {
    if (_repository == null) {
      _historyErrorMessage = "Service not ready";
      _isLoadingHistory = false;
      notifyListeners();
      return;
    }

    _isLoadingHistory = true;
    _historyErrorMessage = null;
    notifyListeners();

    try {
      _historyList = await _repository!.fetchAttendanceHistory();
    } catch (e) {
      _historyErrorMessage = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> handleCheckIn({
    required double latitude,
    required double longitude,
    required String address,
    required String attendanceDate,
    required String checkInTime,
    required String status,
  }) async {
    if (_repository == null) {
      _checkInErrorMessage = "Service not ready";
      _isCheckingIn = false;
      notifyListeners();
      return false;
    }

    _isCheckingIn = true;
    _checkInErrorMessage = null;
    notifyListeners();

    try {
      // 1. Lakukan Check-In
      await _repository!.checkIn(
        latitude: latitude,
        longitude: longitude,
        address: address,
        attendanceDate: attendanceDate,
        checkInTime: checkInTime,
        status: status,
      );

      // 2. KOREKSI: Manual update _todayStatus dengan data yang PASTI ada
      _todayStatus = TodayStatusData(
        // Menggunakan DateTime.parse()
        attendanceDate: DateTime.parse(attendanceDate),
        checkInTime: checkInTime, // String waktu (misal: "08:10")
        checkOutTime: null,
        status: status,
        checkInAddress: address,
        checkOutAddress: null,
      );

      _calculateTodayWorkingHours();

      // 3. Matikan status loading. Ini memicu rebuild di Home Page dengan data baru.
      _isCheckingIn = false;
      notifyListeners();

      // 🛑 fetchTodayStatusData() TIDAK ADA DI SINI

      return true;
    } catch (e) {
      _checkInErrorMessage = e.toString();
      _isCheckingIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleCheckOut({
    required double latitude,
    required double longitude,
    required String address,
    required String attendanceDate,
    required String checkOutTime,
  }) async {
    if (_repository == null) {
      _checkOutErrorMessage = "Service not ready";
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }

    _isCheckingOut = true;
    _checkOutErrorMessage = null;
    notifyListeners();

    try {
      // 1. Lakukan Check-Out
      await _repository!.checkOut(
        latitude: latitude,
        longitude: longitude,
        address: address,
        attendanceDate: attendanceDate,
        checkOutTime: checkOutTime,
      );

      // 2. KOREKSI: Manual update _todayStatus
      if (_todayStatus != null) {
        _todayStatus = TodayStatusData(
          attendanceDate: _todayStatus!.attendanceDate,
          checkInTime: _todayStatus!.checkInTime, // Pertahankan Check-In lama
          checkOutTime: checkOutTime, // Masukkan waktu Check-Out baru
          status: "masuk",
          checkInAddress: _todayStatus!.checkInAddress,
          checkOutAddress: address,
        );
      }

      _calculateTodayWorkingHours();

      _isCheckingOut = false;
      notifyListeners();

      return true;
    } catch (e) {
      _checkOutErrorMessage = e.toString();
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }
}
