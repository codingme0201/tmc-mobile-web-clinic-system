import 'package:flutter/material.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/mock_dashboard_data_source.dart';

enum DashboardStatus { initial, loading, loaded, refreshing, error }

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  DashboardData? _data;
  DashboardStatus _status = DashboardStatus.initial;
  String? _error;

  DashboardData? get data => _data;
  DashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == DashboardStatus.loading;
  bool get isRefreshing => _status == DashboardStatus.refreshing;

  Future<void> loadDashboard() async {
    if (_status == DashboardStatus.loaded) {
      _status = DashboardStatus.refreshing;
    } else {
      _status = DashboardStatus.loading;
    }
    _error = null;
    notifyListeners();

    try {
      _data = await _repository.getDashboardData();
      _status = DashboardStatus.loaded;
    } catch (e) {
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
