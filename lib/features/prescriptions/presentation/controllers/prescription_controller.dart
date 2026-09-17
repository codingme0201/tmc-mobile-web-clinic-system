import 'package:flutter/material.dart';
import '../../domain/models/prescription.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../../data/repositories/prescription_api_repository.dart';

enum PrescriptionListStatus { initial, loading, loaded, error }

class PrescriptionController extends ChangeNotifier {
  final PrescriptionRepository _repository = PrescriptionApiRepository();

  List<Prescription> _prescriptions = [];
  PrescriptionListStatus _status = PrescriptionListStatus.initial;
  String? _error;

  List<Prescription> get prescriptions => _prescriptions;
  PrescriptionListStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == PrescriptionListStatus.loading;

  Future<void> loadPrescriptions() async {
    _status = PrescriptionListStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _prescriptions = await _repository.getMyPrescriptions();
      _status = PrescriptionListStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = PrescriptionListStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
