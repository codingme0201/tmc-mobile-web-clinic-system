import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';
import '../../domain/models/patient_notification.dart';

class NotificationApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<PatientNotification>> getMyNotifications() async {
    final response = await _apiClient.get('/me/notifications');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = (decoded is Map && decoded.containsKey('data'))
          ? decoded['data'] as List
          : (decoded is List ? decoded : []);

      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => PatientNotification.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  Future<void> markAsRead(String id) async {
    final response = await _apiClient.patch('/me/notifications/$id/read');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _apiClient.patch('/me/notifications/read-all');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to mark all notifications as read');
    }
  }
}
