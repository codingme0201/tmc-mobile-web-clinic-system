import 'package:flutter/material.dart';
import '../../domain/models/medical_certificate.dart';
import '../../domain/repositories/medical_certificate_repository.dart';
import '../../data/repositories/medical_certificate_api_repository.dart';

enum MedicalCertificateStatus { initial, loading, loaded, error }

class MedicalCertificateController extends ChangeNotifier {
  final MedicalCertificateRepository _repository = MedicalCertificateApiRepository();

  List<MedicalCertificate> _certificates = [];
  MedicalCertificateStatus _status = MedicalCertificateStatus.initial;
  String? _error;
  bool _isSubmitting = false;

  List<MedicalCertificate> get certificates => _certificates;
  MedicalCertificateStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MedicalCertificateStatus.loading;
  bool get isSubmitting => _isSubmitting;

  /// [silent] refreshes already-loaded data in the background (live
  /// sync) without showing a loading state or replacing it with an error.
  Future<void> loadCertificates({bool silent = false}) async {
    final background = silent && _status == MedicalCertificateStatus.loaded;
    if (!background) {
      _status = MedicalCertificateStatus.loading;
      _error = null;
      notifyListeners();
    }

    try {
      _certificates = await _repository.getMyCertificates();
      _status = MedicalCertificateStatus.loaded;
      _error = null;
    } catch (e) {
      if (background) return;
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = MedicalCertificateStatus.error;
    }
    notifyListeners();
  }

  Future<bool> requestCertificate({
    required String purpose,
    String? diagnosis,
    String? consultationId,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final cert = await _repository.requestCertificate(
        purpose: purpose,
        diagnosis: diagnosis,
        consultationId: consultationId,
      );
      _certificates.insert(0, cert);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
