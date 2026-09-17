import 'package:carelink_mobile/features/dashboard/domain/models/dashboard_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData();
}
