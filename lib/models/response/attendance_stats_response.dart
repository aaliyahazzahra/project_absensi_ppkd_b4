import 'dart:convert';

AttendanceStatsResponse attendanceStatsResponseFromJson(String str) =>
    AttendanceStatsResponse.fromJson(json.decode(str));

String attendanceStatsResponseToJson(AttendanceStatsResponse data) =>
    json.encode(data.toJson());

class AttendanceStatsResponse {
  final String message;
  final AttendanceStatsData? data;

  AttendanceStatsResponse({required this.message, this.data});

  factory AttendanceStatsResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceStatsResponse(
        message: json["message"],
        data: json["data"] == null
            ? null
            : AttendanceStatsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class AttendanceStatsData {
  final int totalAbsen; // Total hari tidak hadir
  final int totalMasuk; // Total hari hadir
  final int totalIzin; // Total hari izin
  final bool sudahAbsenHariIni;

  AttendanceStatsData({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory AttendanceStatsData.fromJson(Map<String, dynamic> json) =>
      AttendanceStatsData(
        totalAbsen: json["total_absen"] is int
            ? json["total_absen"]
            : int.tryParse(json["total_absen"]?.toString() ?? '0') ?? 0,
        totalMasuk: json["total_masuk"] is int
            ? json["total_masuk"]
            : int.tryParse(json["total_masuk"]?.toString() ?? '0') ?? 0,
        totalIzin: json["total_izin"] is int
            ? json["total_izin"]
            : int.tryParse(json["total_izin"]?.toString() ?? '0') ?? 0,
        sudahAbsenHariIni: json["sudah_absen_hari_ini"],
      );

  Map<String, dynamic> toJson() => {
    "total_absen": totalAbsen,
    "total_masuk": totalMasuk,
    "total_izin": totalIzin,
    "sudah_absen_hari_ini": sudahAbsenHariIni,
  };
}
