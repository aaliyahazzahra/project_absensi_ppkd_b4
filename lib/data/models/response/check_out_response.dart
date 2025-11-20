import 'dart:convert';

CheckOutResponse checkOutResponseFromJson(String str) =>
    CheckOutResponse.fromJson(json.decode(str));

class CheckOutResponse {
  String? message;
  CheckOutData? data; 

  CheckOutResponse({this.message, this.data});

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) =>
      CheckOutResponse(
        message: json["message"],
        data: json["data"] == null ? null : CheckOutData.fromJson(json["data"]),
      );
}

class CheckOutData {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? checkInAddress;
  String? checkOutAddress;
  String? checkInLocation;
  String? checkOutLocation;
  String? status;
  dynamic alasanIzin;

  CheckOutData({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress, 
    this.checkOutAddress, 
    this.checkInLocation, 
    this.checkOutLocation, 
    this.status,
    this.alasanIzin,
  });

  factory CheckOutData.fromJson(Map<String, dynamic> json) => CheckOutData(
    id: json["id"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    checkInLocation: json["check_in_location"],
    checkOutLocation: json["check_out_location"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );
}
