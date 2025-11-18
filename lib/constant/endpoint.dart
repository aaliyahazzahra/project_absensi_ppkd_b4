class Endpoints {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login";

  static const String profile = "$baseUrl/profile";
  static const String updateProfile = '$baseUrl/profile';
  static const String todayStatus = '$baseUrl/api/absen/today';
  static const String editProfilePhoto = "$baseUrl/profile/photo";

  static const String checkIn = "$baseUrl/absen/check-in";
  static const String checkOut = "$baseUrl/absen/check-out";
  static const String historyAbsen = "$baseUrl/absen/history";

  static const String trainings = "$baseUrl/trainings";
  static const String batches = "$baseUrl/batches";
}
