import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';
import 'package:carelink_mobile/core/models/appointment.dart';

class AppointmentApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Appointment>> getMyAppointments() async {
    final response = await _apiClient.get('/me/appointments');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is Map ? (decoded['data'] ?? []) : (decoded as List);

      return list.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load appointments: ${response.statusCode}');
    }
  }

  Future<Appointment?> getAppointmentById(String id) async {
    final response = await _apiClient.get('/me/appointments/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final item = data is Map && data['data'] != null ? data['data'] : data;
      return Appointment.fromJson(item as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getClinicians() async {
    final response = await _apiClient.get('/me/appointment-options');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map ? (decoded['data'] ?? {}) : {};
      final doctors = (data is Map ? data['doctors'] : null) as List? ?? [];
      return doctors.whereType<Map<String, dynamic>>().toList();
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> getUnavailableSlots(String date, {int? staffId}) async {
    final response = await _apiClient.get('/me/appointments/availability', queries: {
      'date': date,
      if (staffId != null) 'staff_id': staffId.toString(),
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map ? (decoded['data'] ?? {}) : {};
      final slots = (data is Map ? data['slots'] : null) as List? ?? [];
      return {
        for (final slot in slots.whereType<Map<String, dynamic>>())
          if (slot['available'] != true) slot['time'].toString(): (slot['reason'] ?? 'booked').toString(),
      };
    } else {
      throw Exception('Failed to load slot availability: ${response.statusCode}');
    }
  }

  Future<Appointment> requestAppointment({
    required String type,
    required String reason,
    required String date,
    required String time,
    String? staff,
    int? staffId,
  }) async {
    final response = await _apiClient.post('/me/appointments', body: {
      'type': type,
      'reason': reason,
      'date': date,
      'time': time,
      'staff': staff,
      'staff_id': ?staffId,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final json = data is Map && data['data'] != null ? data['data'] : data;

      return Appointment.fromJson(json as Map<String, dynamic>);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to request appointment');
    }
  }

  Future<Appointment> rescheduleAppointment(
    String id,
    DateTime newDate,
    String newTime, {
    String? reason,
  }) async {
    final dateStr = '${newDate.year.toString().padLeft(4, '0')}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';
    final response = await _apiClient.post(
      '/me/appointments/$id/reschedule',
      body: {
        'date': dateStr,
        'time': newTime,
        'reason': reason,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final json = data is Map && data['data'] != null ? data['data'] : data;
      return Appointment.fromJson(json as Map<String, dynamic>);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to reschedule appointment');
    }
  }

  Future<Appointment> cancelAppointment(String id, {String? reason}) async {
    final response = await _apiClient.post(
      '/me/appointments/$id/cancel',
      body: {'reason': reason},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final json = data is Map && data['data'] != null ? data['data'] : data;
      return Appointment.fromJson(json as Map<String, dynamic>);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to cancel appointment');
    }
  }
}
