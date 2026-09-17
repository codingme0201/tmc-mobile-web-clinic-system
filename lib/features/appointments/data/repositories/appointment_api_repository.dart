import 'package:carelink_mobile/core/models/appointment.dart';
import 'package:carelink_mobile/features/appointments/data/repositories/appointment_repository.dart';
import 'package:carelink_mobile/features/appointments/data/datasources/appointment_api_data_source.dart';

class AppointmentApiRepository extends AppointmentRepository {
  final AppointmentApiDataSource _dataSource = AppointmentApiDataSource();

  @override
  Future<List<Appointment>> getAppointments() async {
    return await _dataSource.getMyAppointments();
  }

  @override
  Future<Appointment?> getAppointmentById(String id) async {
    return await _dataSource.getAppointmentById(id);
  }

  @override
  Future<List<Appointment>> getUpcomingAppointments() async {
    final all = await getAppointments();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return !aDate.isBefore(today) && a.status != AppointmentStatus.completed && a.status != AppointmentStatus.cancelled;
    }).toList();
  }

  @override
  Future<List<Appointment>> getAppointmentHistory() async {
    final all = await getAppointments();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return aDate.isBefore(today) || a.status == AppointmentStatus.completed || a.status == AppointmentStatus.cancelled;
    }).toList();
  }

  @override
  Future<Map<String, int>> getStatusCounts() async {
    final all = await getAppointments();
    final counts = <String, int>{
      'pending': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
      'upcoming': 0,
    };
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var a in all) {
      final key = a.status.name;
      counts[key] = (counts[key] ?? 0) + 1;

      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      if (!aDate.isBefore(today) && a.status != AppointmentStatus.completed && a.status != AppointmentStatus.cancelled) {
        counts['upcoming'] = (counts['upcoming'] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<Appointment> createAppointment({
    required String title,
    required String reason,
    required DateTime date,
    required String time,
    required String doctorName,
    required String type,
    required String clinic,
  }) async {
    final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return await _dataSource.requestAppointment(
      type: type,
      reason: reason,
      date: dateStr,
      time: time,
      staff: doctorName,
    );
  }

  @override
  Future<Appointment?> rescheduleAppointment(String id, DateTime newDate, String newTime) async {
    return await _dataSource.rescheduleAppointment(id, newDate, newTime);
  }

  @override
  Future<Appointment?> cancelAppointment(String id, {String? reason}) async {
    return await _dataSource.cancelAppointment(id, reason: reason);
  }

  @override
  List<String> getAvailableTimeSlots() => [
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
  ];

  @override
  List<String> getDoctorNames() => [
    'Dr. R. Mendoza',
    'Dr. Ana Cruz',
    'Dr. S. Lopez',
    'Nurse C. Villanueva',
    'Nurse J. Santos',
  ];

  @override
  List<String> getAppointmentTypes() => [
    'Check-up',
    'Consultation',
    'Follow-up',
    'Dental concern',
    'Vaccination',
    'Emergency',
  ];
}
