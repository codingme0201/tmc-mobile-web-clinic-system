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

  /// [silent] refreshes already-loaded data in the background (live
  /// sync) without showing a loading state or replacing it with an error.
  Future<void> loadConsultations({bool silent = false}) async {
    final background = silent && _status == ConsultationListStatus.loaded;
    if (!background) {
      _status = ConsultationListStatus.loading;
      _error = null;
      notifyListeners();
    }

    try {
      _consultations = await _repository.getMyConsultations();
      _status = ConsultationListStatus.loaded;
      _error = null;
    } catch (e) {
      if (background) return;
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
