// Untuk parsing dari JSON ke objek Dart
import 'dart:convert';

// Ganti nama fungsi dari historyFromJson menjadi historyResponseFromJson
HistoryResponse historyResponseFromJson(String str) =>
    HistoryResponse.fromJson(json.decode(str));

String historyResponseToJson(HistoryResponse data) =>
    json.encode(data.toJson());

// Ganti nama class History menjadi HistoryResponse
class HistoryResponse {
  final String message;
  final List<HistoryData> data; // Gunakan HistoryData

  HistoryResponse({required this.message, required this.data});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) =>
      HistoryResponse(
        message: json["message"],
        // Pastikan list tidak null
        data: List<HistoryData>.from(
          (json["data"] ?? []).map((x) => HistoryData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

// Ganti nama class Datum menjadi HistoryData (sesuai konvensi sebelumnya)
class HistoryData {
  final int id;
  final DateTime attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? alasanIzin;

  HistoryData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime, // Dibuat nullable, required dihapus
    this.checkOutTime, // Dibuat nullable, required dihapus
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    this.alasanIzin, // Dibuat nullable, required dihapus
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) => HistoryData(
    id: json["id"],
    // Parsing DateTime
    attendanceDate: DateTime.parse(json["attendance_date"]),

    // Asumsi API menggunakan key: check_in dan check_out (sesuai model lama)
    // Jika API Anda menggunakan 'check_in_time' dan 'check_out_time', ganti di sini:
    checkInTime: json["check_in_time"] ?? json["check_in"],
    checkOutTime: json["check_out_time"] ?? json["check_out"],

    // Mapping double, menggunakan toDouble() dan null-safety
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),

    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    checkInLocation: json["check_in_location"],
    checkOutLocation: json["check_out_location"],

    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",

    // Menggunakan nama key yang diprediksi digunakan oleh API (jika ada)
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,

    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
