import '../datasources/mock_appointment_data_source.dart';
import '../../../../core/models/appointment.dart';

class AppointmentRepository {
  final MockAppointmentDataSource _dataSource = MockAppointmentDataSource.instance;

  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _dataSource.getAppointments();
  }

  Future<Appointment?> getAppointmentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dataSource.getAppointmentById(id);
  }

  Future<List<Appointment>> getUpcomingAppointments() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _dataSource.getUpcomingAppointments();
  }

  Future<List<Appointment>> getAppointmentHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _dataSource.getAppointmentHistory();
  }

  Future<Map<String, int>> getStatusCounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dataSource.getStatusCounts();
  }

  Future<Appointment> createAppointment({
    required String title,
    required String reason,
    required DateTime date,
    required String time,
    required String doctorName,
    required String type,
    required String clinic,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataSource.createAppointment(
      title: title,
      reason: reason,
      date: date,
      time: time,
      doctorName: doctorName,
      type: type,
      clinic: clinic,
    );
  }

  Future<Appointment?> rescheduleAppointment(
      String id, DateTime newDate, String newTime) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataSource.rescheduleAppointment(id, newDate, newTime);
  }

  Future<Appointment?> cancelAppointment(String id, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _dataSource.cancelAppointment(id, reason: reason);
  }

  List<String> getAvailableTimeSlots() {
    return _dataSource.getAvailableTimeSlots();
  }

  List<String> getDoctorNames() {
    return _dataSource.getDoctorNames();
  }

  List<String> getAppointmentTypes() {
    return _dataSource.getAppointmentTypes();
  }
}
