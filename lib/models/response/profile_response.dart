import 'dart:convert';

ProfileResponse profileFromJson(String str) =>
    ProfileResponse.fromJson(json.decode(str));

String profileToJson(ProfileResponse data) => json.encode(data.toJson());

class ProfileResponse {
  String? message;
  Data? data;

  ProfileResponse({this.message, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  final int? id;
  final String? name;
  final String? email;
  final String? jenisKelamin;
  final String? profilePhoto;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int? batchId;
  final String? trainingId;
  final Training? training;
  final Batch? batch;

  Data({
    this.id,
    this.name,
    this.email,
    this.jenisKelamin,
    this.profilePhoto,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.batchId,
    this.trainingId,
    this.training,
    this.batch,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    jenisKelamin: json["jenis_kelamin"] as String?,
    profilePhoto: json["profile_photo"] as String?,
    emailVerifiedAt: json["email_verified_at"] == null
        ? null
        : DateTime.parse(json["email_verified_at"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    batchId: json["batch_id"] as int?,
    trainingId: json["training_id"] as String?,
    training: json["training"] == null
        ? null
        : Training.fromJson(json["training"]),
    batch: json["batch"] == null ? null : Batch.fromJson(json["batch"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "batch_id": batchId,
    "training_id": trainingId,
    "training": training?.toJson(),
    "batch": batch?.toJson(),
  };

  Data copyWith({
    int? id,
    String? name,
    String? email,
    String? jenisKelamin,
    String? profilePhoto,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? batchId,
    String? trainingId,
    Training? training,
    Batch? batch,
  }) {
    return Data(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      batchId: batchId ?? this.batchId,
      trainingId: trainingId ?? this.trainingId,
      training: training ?? this.training,
      batch: batch ?? this.batch,
    );
  }
}

class Training {
  final int? id;
  final String? title;
  final String? description;
  final String? duration;

  Training({this.id, this.title, this.description, this.duration});

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    duration: json["duration"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "duration": duration,
  };
}

class Batch {
  final int? id;
  final String? name;
  final String? startDate;
  final String? endDate;

  Batch({this.id, this.name, this.startDate, this.endDate});

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json["id"],
    name: json["name"],
    startDate: json["start_date"],
    endDate: json["end_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "start_date": startDate,
    "end_date": endDate,
  };
}
