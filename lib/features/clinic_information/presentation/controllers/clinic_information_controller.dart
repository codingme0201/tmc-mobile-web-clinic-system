import 'package:flutter/material.dart';
import '../../domain/repositories/clinic_information_repository.dart';
import '../../data/repositories/clinic_info_api_repository.dart';
import '../../domain/models/clinic_information.dart';

enum ClinicInfoStatus { initial, loading, loaded, error }

class ClinicInformationController extends ChangeNotifier {
  final ClinicInformationRepository _repository = ClinicInfoApiRepository();

  ClinicInformation? _data;
  ClinicInfoStatus _status = ClinicInfoStatus.initial;
  String? _error;

  ClinicInformation? get data => _data;
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
