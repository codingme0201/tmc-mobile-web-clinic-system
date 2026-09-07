import '../datasources/mock_dashboard_data_source.dart';

class DashboardRepository {
  final MockDashboardDataSource _dataSource = MockDashboardDataSource.instance;

  Future<DashboardData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataSource.getDashboardData();
  }
}
