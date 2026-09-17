import 'package:flutter/material.dart';
import 'package:carelink_mobile/features/consultations/domain/models/consultation.dart';
import 'package:carelink_mobile/features/consultations/domain/repositories/consultation_repository.dart';
import 'package:carelink_mobile/features/consultations/data/repositories/consultation_api_repository.dart';

enum ConsultationListStatus { initial, loading, loaded, error }

class ConsultationController extends ChangeNotifier {
  final ConsultationRepository _repository = ConsultationApiRepository();

  List<Consultation> _consultations = [];
  ConsultationListStatus _status = ConsultationListStatus.initial;
  String? _error;

  List<Consultation> get consultations => _consultations;
  ConsultationListStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ConsultationListStatus.loading;

  Future<void> loadConsultations() async {
    _status = ConsultationListStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _consultations = await _repository.getMyConsultations();
      _status = ConsultationListStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = ConsultationListStatus.error;
    }
    notifyListeners();
  }

  Future<Consultation> getConsultationDetails(String id) async {
    return await _repository.getConsultationById(id);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
