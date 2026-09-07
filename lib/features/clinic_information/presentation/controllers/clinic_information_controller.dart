import 'package:flutter/material.dart';
import '../../data/repositories/clinic_information_repository.dart';
import '../../data/datasources/mock_clinic_information_data_source.dart';

enum ClinicInfoStatus { initial, loading, loaded, error }

class ClinicInformationController extends ChangeNotifier {
  final ClinicInformationRepository _repository = ClinicInformationRepository();

  ClinicInformationData? _data;
  ClinicInfoStatus _status = ClinicInfoStatus.initial;
  String? _error;

  ClinicInformationData? get data => _data;
  ClinicInfoStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ClinicInfoStatus.loading;

  Future<void> loadClinicInformation() async {
    _status = ClinicInfoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _data = await _repository.getClinicInformation();
      _status = ClinicInfoStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = ClinicInfoStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
