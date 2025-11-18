import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:project_absensi_ppkd_b4/models/response/auth_response.dart'
    as auth;
import 'package:project_absensi_ppkd_b4/models/response/batches_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/check_in_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/check_out_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/profile_response.dart'
    as profile;
import 'package:project_absensi_ppkd_b4/models/response/today_status_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/endpoint.dart';
import '../models/response/training_response.dart';

typedef TrainingData = Training;
typedef BatchData = Batch;

class ApiService {
  Future<auth.Data> register({
    required String name,
    required String email,
    required String password,
    required String? jenisKelamin, // "L" atau "P"
    required String profilePhoto, // base64 string
    required int? batchId,
    required int? trainingId,
  }) async {
    try {
      if (jenisKelamin == null || batchId == null || trainingId == null) {
        throw Exception('Please fill all required fields');
      }

      final response = await http.post(
        Uri.parse(Endpoints.register),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'jenis_kelamin': jenisKelamin,
          'profile_photo': profilePhoto,
          'batch_id': batchId,
          'training_id': trainingId,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = auth.AuthResponse.fromJson(responseBody);
        final data = authResponse.data;

        if (data != null && data.token != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data.token!);

          return data;
        } else {
          throw Exception('Registration successful but no data received');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<TrainingData>> getTrainings() async {
    try {
      final response = await http.get(
        Uri.parse(Endpoints.trainings),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final trainingResponse = trainingsResponseFromJson(response.body);
        return trainingResponse.data ?? [];
      } else {
        throw Exception('Failed to load trainings');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<BatchData>> getBatches() async {
    try {
      final response = await http.get(
        Uri.parse(Endpoints.batches),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final batchResponse = batchesResponseFromJson(response.body);
        return batchResponse.data ?? [];
      } else {
        throw Exception('Failed to load batches');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<auth.Data> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoints.login),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = auth.AuthResponse.fromJson(responseBody);
        final data = authResponse.data;

        if (data != null && data.token != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data.token!);

          return data;
        } else {
          throw Exception('Login successful but no data received');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<CheckInData> checkIn({
    required double latitude,
    required double longitude,
    required String address,
    required String attendanceDate,
    required String checkInTime,
    required String status,
  }) async {
    final String? token = await _getToken();
    if (token == null) throw Exception('Token not found');

    try {
      final response = await http.post(
        Uri.parse(Endpoints.checkIn),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Tambahkan parameter baru ke body
        body: jsonEncode({
          'check_in_lat': latitude,
          'check_in_lng': longitude,
          'check_in_address': address,
          'attendance_date': attendanceDate,
          'check_in': checkInTime,
          'status': status,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final checkInResponse = CheckInResponse.fromJson(responseBody);
        if (checkInResponse.data != null) {
          return checkInResponse.data!;
        } else {
          throw Exception('Check-in successful but no data received');
        }
      } else {
        // Parsing error dari Laravel
        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values.map((e) => e[0]).join('. ');
          throw Exception('Check-in Failed: $errorMessages');
        }
        throw Exception(responseBody['message'] ?? 'Check-in failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<CheckOutData> checkOut({
    required double latitude,
    required double longitude,
    required String address,
    required String attendanceDate,
    required String checkOutTime,
  }) async {
    final String? token = await _getToken();
    if (token == null) throw Exception('Token not found');

    try {
      final response = await http.post(
        Uri.parse(Endpoints.checkOut),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Tambahkan parameter baru ke body
        body: jsonEncode({
          'check_out_lat': latitude,
          'check_out_lng': longitude,
          'check_out_address': address,
          'attendance_date': attendanceDate,
          'check_out': checkOutTime,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final checkOutResponse = CheckOutResponse.fromJson(responseBody);
        if (checkOutResponse.data != null) {
          return checkOutResponse.data!;
        } else {
          throw Exception('Check-out successful but no data received');
        }
      } else {
        // Parsing error dari Laravel
        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values.map((e) => e[0]).join('. ');
          throw Exception('Check-out Failed: $errorMessages');
        }
        throw Exception(responseBody['message'] ?? 'Check-out failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<profile.Data> getProfile() async {
    final String? token = await _getToken();
    if (token == null) throw Exception('Token not found. Please login again.');

    try {
      final response = await http.get(
        Uri.parse(Endpoints.profile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final profileResponse = profile.ProfileResponse.fromJson(responseBody);
        if (profileResponse.data != null) {
          return profileResponse.data!;
        } else {
          throw Exception('Profile data not found in response');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<profile.Data> updateProfile({
    required String name,
    required String email,
    // TODO: Tambahkan field lain jika ada (misal: password)
  }) async {
    final String? token = await _getToken();
    if (token == null) throw Exception('Token not found. Please login again.');

    try {
      final response = await http.post(
        Uri.parse(Endpoints.updateProfile),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final profileResponse = profile.ProfileResponse.fromJson(responseBody);
        if (profileResponse.data != null) {
          return profileResponse.data!;
        } else {
          throw Exception('Profile update successful but no data received');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<TodayStatusData?> getTodayStatus() async {
    final String? token = await _getToken();
    if (token == null) throw Exception('Token not found. Please login again.');

    // 1. Dapatkan tanggal hari ini dalam format YYYY-MM-DD
    final String today = DateTime.now().toIso8601String().split('T').first;

    // 2. Buat URL dengan query parameter
    final Uri url = Uri.parse(
      Endpoints.todayStatus,
    ).replace(queryParameters: {'attendance_date': today});

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final statusResponse = TodayStatusResponse.fromJson(responseBody);
        return statusResponse.data;
      } else {
        throw Exception(
          responseBody['message'] ?? 'Failed to load today status',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<void> _removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> logout() async {
    // Catatan: Logout yang baik juga memanggil API server
    // (misal: http.post(Endpoints.logout)) untuk membatalkan token di sisi server.
    //
    // Tapi untuk sekarang, menghapus token lokal sudah 100% cukup
    // untuk meng-logout-kan user dari APLIKASI.

    try {
      await _removeToken();
    } catch (e) {
      throw Exception('Failed to remove token: $e');
    }
  }
}
