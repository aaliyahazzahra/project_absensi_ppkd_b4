import 'package:project_absensi_ppkd_b4/service/api_service.dart';
import 'package:project_absensi_ppkd_b4/models/response/batches_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/training_response.dart';

class DropdownRepository {
  final ApiService _apiService;

  DropdownRepository({required ApiService apiService})
    : _apiService = apiService;

  // getBatches() mengembalikan List<BatchData>, yaitu typedef untuk List<Batch>
  Future<List<Batch>> fetchBatches() async {
    return await _apiService.getBatches();
  }

  // getTrainings() mengembalikan List<TrainingData>, yaitu typedef untuk List<Training>
  Future<List<Training>> fetchTrainings() async {
    return await _apiService.getTrainings();
  }
}
