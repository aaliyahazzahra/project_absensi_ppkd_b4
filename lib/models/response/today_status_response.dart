import 'dart:convert';

TodayStatusResponse todayStatusResponseFromJson(String str) =>
    TodayStatusResponse.fromJson(json.decode(str));

String todayStatusResponseToJson(TodayStatusResponse data) =>
    json.encode(data.toJson());

class TodayStatusResponse {
  String? message;
  TodayStatusData? data;

  TodayStatusResponse({this.message, this.data});

  factory TodayStatusResponse.fromJson(Map<String, dynamic> json) =>
      TodayStatusResponse(
        message: json["message"],
        data: json["data"] == null
            ? null
            : TodayStatusData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class TodayStatusData {
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? checkInAddress;
  String? checkOutAddress;
  String? status;
  String? alasanIzin;

  TodayStatusData({
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
  });

  factory TodayStatusData.fromJson(Map<String, dynamic> json) =>
      TodayStatusData(
        attendanceDate: json["attendance_date"] == null
            ? null
            : DateTime.parse(json["attendance_date"]),
        checkInTime: json["check_in_time"],
        checkOutTime: json["check_out_time"],
        checkInAddress: json["check_in_address"],
        checkOutAddress: json["check_out_address"],
        status: json["status"],
        alasanIzin: json["alasan_izin"],
      );

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate?.toIso8601String().split('T').first,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
