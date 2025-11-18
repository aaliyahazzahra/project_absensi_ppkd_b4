import 'package:project_absensi_ppkd_b4/models/response/check_in_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/check_out_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/today_status_response.dart';
import 'package:project_absensi_ppkd_b4/service/api_service.dart';

class AttendanceRepository {
  final ApiService _apiService;

  AttendanceRepository({required ApiService apiService})
    : _apiService = apiService;

  // Mengambil status absensi hari ini
  Future<TodayStatusData?> fetchTodayStatus() async {
    try {
      final statusData = await _apiService.getTodayStatus();
      return statusData;
    } catch (e) {
      rethrow;
    }
  }

  Future<CheckInData> checkIn({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final checkInData = await _apiService.checkIn(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      return checkInData;
    } catch (e) {
      rethrow;
    }
  }

  Future<CheckOutData> checkOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      // Panggil fungsi checkOut dari ApiService
      final checkOutData = await _apiService.checkOut(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      return checkOutData;
    } catch (e) {
      // Teruskan error (misal: "Belum check in") ke Provider
      rethrow;
    }
  }
}
