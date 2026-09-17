import '../../domain/models/patient_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_api_data_source.dart';

class NotificationApiRepository implements NotificationRepository {
  final NotificationApiDataSource _dataSource = NotificationApiDataSource();

  @override
  Future<List<PatientNotification>> getMyNotifications() async {
    return await _dataSource.getMyNotifications();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _dataSource.markAllAsRead();
  }
}
