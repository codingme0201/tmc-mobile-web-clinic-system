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

  /// [silent] refreshes already-loaded data in the background (live
  /// sync) without showing a loading state or replacing it with an error.
  Future<void> loadClinicInformation({bool silent = false}) async {
    final background = silent && _status == ClinicInfoStatus.loaded;
    if (!background) {
      _status = ClinicInfoStatus.loading;
      _error = null;
      notifyListeners();
    }

    try {
      _data = await _repository.getClinicInformation();
      _status = ClinicInfoStatus.loaded;
      _error = null;
    } catch (e) {
      if (background) return;
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
