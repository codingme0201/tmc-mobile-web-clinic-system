import 'package:flutter/material.dart';
import 'package:carelink_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:carelink_mobile/features/dashboard/data/repositories/dashboard_api_repository.dart';

enum DashboardStatus { initial, loading, loaded, refreshing, error }

class DashboardController extends ChangeNotifier {
  final DashboardApiRepository _repository = DashboardApiRepository();

  DashboardData? _data;
  DashboardStatus _status = DashboardStatus.initial;
  String? _error;

  DashboardData? get data => _data;
  DashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == DashboardStatus.loading;
  bool get isRefreshing => _status == DashboardStatus.refreshing;

  /// [silent] refreshes already-loaded data in the background (live sync)
  /// without the refreshing overlay or replacing it with an error.
  Future<void> loadDashboard({bool silent = false}) async {
    final background = silent && _status == DashboardStatus.loaded;
    if (!background) {
      _status = _status == DashboardStatus.loaded ? DashboardStatus.refreshing : DashboardStatus.loading;
      _error = null;
      notifyListeners();
    }

    try {
      _data = await _repository.getDashboardData();
      _status = DashboardStatus.loaded;
      _error = null;
    } catch (e) {
      if (background) return;
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = DashboardStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
