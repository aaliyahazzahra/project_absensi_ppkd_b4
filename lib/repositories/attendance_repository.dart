import 'package:project_absensi_ppkd_b4/models/response/check_in_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/check_out_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/today_status_response.dart';
import 'package:project_absensi_ppkd_b4/service/api_service.dart';

class AttendanceRepository {
  final ApiService _apiService;

  AttendanceRepository({required ApiService apiService})
    : _apiService = apiService;

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
    required String attendanceDate,
    required String checkInTime,
    required String status,
  }) async {
    try {
      final checkInData = await _apiService.checkIn(
        latitude: latitude,
        longitude: longitude,
        address: address,
        attendanceDate: attendanceDate,
        checkInTime: checkInTime,
        status: status,
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
    required String attendanceDate,
    required String checkOutTime,
  }) async {
    try {
      final checkOutData = await _apiService.checkOut(
        latitude: latitude,
        longitude: longitude,
        address: address,
        attendanceDate: attendanceDate,
        checkOutTime: checkOutTime,
      );
      return checkOutData;
    } catch (e) {
      rethrow;
    }
  }
}
