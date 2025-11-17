import 'dart:convert';

TrainingsResponse trainingsResponseFromJson(String str) =>
    TrainingsResponse.fromJson(json.decode(str));

String trainingsResponseToJson(TrainingsResponse data) =>
    json.encode(data.toJson());

class TrainingsResponse {
  String? message;
  List<Training>? data;

  TrainingsResponse({this.message, this.data});

  factory TrainingsResponse.fromJson(Map<String, dynamic> json) =>
      TrainingsResponse(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Training>.from(
                json["data"]!.map((x) => Training.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Training {
  int? id;
  String? title;

  Training({this.id, this.title});

  factory Training.fromJson(Map<String, dynamic> json) =>
      Training(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
