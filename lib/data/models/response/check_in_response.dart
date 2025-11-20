import 'dart:convert';

CheckInResponse checkInResponseFromJson(String str) =>
    CheckInResponse.fromJson(json.decode(str));

class CheckInResponse {
  String? message;
  CheckInData? data; 

  CheckInResponse({this.message, this.data});

  factory CheckInResponse.fromJson(Map<String, dynamic> json) =>
      CheckInResponse(
        message: json["message"],
        data: json["data"] == null ? null : CheckInData.fromJson(json["data"]),
      );
}

class CheckInData {
  int? id;
  int? userId;
  DateTime? checkIn;
  String? checkInLocation;
  String? checkInAddress;
  dynamic checkOut;
  dynamic checkOutLocation;
  dynamic checkOutAddress;
  String? status;
  dynamic alasanIzin;
  DateTime? createdAt;
  DateTime? updatedAt;
  double? checkInLat;
  double? checkInLng;
  double? checkOutLat;
  double? checkOutLng;

  CheckInData({
    this.id,
    this.userId,
    this.checkIn,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) => CheckInData(
    id: json["id"],
    userId: json["user_id"],
    checkIn: json["check_in"] == null ? null : DateTime.parse(json["check_in"]),
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    checkOut: json["check_out"],
    checkOutLocation: json["check_out_location"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
  );
}
