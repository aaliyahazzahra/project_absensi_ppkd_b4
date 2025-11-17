import 'dart:convert';

import 'package:http/http.dart' as http;
// --- PERBAIKAN 1: Beri alias 'as auth' ---
import 'package:project_absensi_ppkd_b4/models/response/auth_response.dart'
    as auth;
import 'package:project_absensi_ppkd_b4/models/response/batches_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/check_in_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/check_out_response.dart';
// --- PERBAIKAN 2: Beri alias 'as profile' (dan hapus impor duplikat) ---
import 'package:project_absensi_ppkd_b4/models/response/profile_response.dart'
    as profile;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/endpoint.dart';
import '../models/response/training_response.dart';

typedef TrainingData = Training;
typedef BatchData = Batch;

class ApiService {
  // --- PERBAIKAN 3: Ubah return type 'Data' menjadi 'auth.Data' ---
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
      // Validasi input
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
        // --- PERBAIKAN 4: Gunakan 'auth.AuthResponse.fromJson' ---
        final authResponse = auth.AuthResponse.fromJson(responseBody);
        final data = authResponse.data;

        if (data != null && data.token != null) {
          // 2. Simpan token
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data.token!);

          // 3. Kembalikan data
          return data;
        } else {
          throw Exception('Registration successful but no data received');
        }
      } else {
        // Handle error (misal: email sudah terdaftar 422)
        throw Exception(responseBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // --- GET TRAININGS (Sudah Benar) ---
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

  // --- GET BATCHES (Sudah Benar) ---
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

  // --- LOGIN (SESUAI POSTMAN 1.2) ---
  // --- PERBAIKAN 5: Ubah return type 'Data' menjadi 'auth.Data' ---
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
        // --- PERBAIKAN 6: Gunakan 'auth.AuthResponse.fromJson' ---
        final authResponse = auth.AuthResponse.fromJson(responseBody);
        final data = authResponse.data;

        if (data != null && data.token != null) {
          // 2. Simpan token ke SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data.token!);

          // 3. Kembalikan data (Token + User)
          return data;
        } else {
          throw Exception('Login successful but no data received');
        }
      } else {
        // Handle error (misal 401 atau 404)
        throw Exception(responseBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Handle error koneksi
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- CHECK IN (Sudah Benar) ---
  Future<CheckInData> checkIn({
    required double latitude,
    required double longitude,
    required String address,
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
        body: jsonEncode({
          'check_in_lat': latitude,
          'check_in_lng': longitude,
          'check_in_address': address,
          'status': 'masuk',
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
        throw Exception(responseBody['message'] ?? 'Check-in failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // --- CHECK OUT (Sudah Benar) ---
  Future<CheckOutData> checkOut({
    required double latitude,
    required double longitude,
    required String address,
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
        body: jsonEncode({
          'check_out_lat': latitude,
          'check_out_lng': longitude,
          'check_out_address': address,
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
        throw Exception(responseBody['message'] ?? 'Check-out failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // --- BARU: Get Profile (Sesuai PDF 4.1) ---
  // --- PERBAIKAN 7: Return type 'profile.Data' sudah benar ---
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
        // --- PERBAIKAN 8: Gunakan 'profile.ProfileResponse.fromJson' ---
        final profileResponse = profile.ProfileResponse.fromJson(responseBody);
        if (profileResponse.data != null) {
          // Kembalikan hanya data User
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
}
