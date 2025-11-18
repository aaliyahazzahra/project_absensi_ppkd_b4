import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/repositories/dropdown_repository.dart';
import 'package:project_absensi_ppkd_b4/models/response/batches_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/training_response.dart';

class DropdownProvider with ChangeNotifier {
  final DropdownRepository _repository;
  DropdownProvider({required DropdownRepository repository})
    : _repository = repository;

  bool _isLoading = true;
  List<Batch> _batchList = [];
  List<Training> _trainingList = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Batch> get batchList => _batchList;
  List<Training> get trainingList => _trainingList;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDropdownData() async {
    if (!_isLoading || _batchList.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _repository.fetchBatches(),
        _repository.fetchTrainings(),
      ]);

      _batchList = responses[0] as List<Batch>;
      _trainingList = responses[1] as List<Training>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
