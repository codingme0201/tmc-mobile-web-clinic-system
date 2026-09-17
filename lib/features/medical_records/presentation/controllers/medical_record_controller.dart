import 'package:flutter/material.dart';
import 'package:carelink_mobile/features/medical_records/domain/models/medical_record.dart';
import 'package:carelink_mobile/features/medical_records/domain/repositories/medical_record_repository.dart';
import 'package:carelink_mobile/features/medical_records/data/repositories/medical_record_api_repository.dart';

enum MedicalRecordStatus { initial, loading, loaded, error }

class MedicalRecordController extends ChangeNotifier {
  final MedicalRecordRepository _repository = MedicalRecordApiRepository();

  MedicalRecord? _medicalRecord;
  MedicalRecordStatus _status = MedicalRecordStatus.initial;
  String? _error;

  MedicalRecord? get medicalRecord => _medicalRecord;
  MedicalRecordStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MedicalRecordStatus.loading;

  Future<void> loadMedicalRecord() async {
    _status = MedicalRecordStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _medicalRecord = await _repository.getMyMedicalRecord();
      _status = MedicalRecordStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = MedicalRecordStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
