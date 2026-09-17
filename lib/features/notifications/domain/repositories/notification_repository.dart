import '../models/patient_notification.dart';

abstract class NotificationRepository {
  Future<List<PatientNotification>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
