import 'package:flutter/material.dart';
import '../../domain/models/patient_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_api_repository.dart';

enum NotificationListStatus { initial, loading, loaded, error }

class NotificationController extends ChangeNotifier {
  final NotificationRepository _repository = NotificationApiRepository();

  List<PatientNotification> _notifications = [];
  NotificationListStatus _status = NotificationListStatus.initial;
  String? _error;

  List<PatientNotification> get notifications => _notifications;
  NotificationListStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == NotificationListStatus.loading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _status = NotificationListStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getMyNotifications();
      _status = NotificationListStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = NotificationListStatus.error;
    }
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
