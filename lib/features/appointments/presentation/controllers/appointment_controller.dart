import 'package:flutter/material.dart';
import '../../data/repositories/appointment_api_repository.dart';
import '../../../../core/models/appointment.dart';

enum AppointmentListStatus { initial, loading, loaded, error }

class AppointmentController extends ChangeNotifier {
  final AppointmentApiRepository _repository = AppointmentApiRepository();

  List<Appointment> _appointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _appointmentHistory = [];
  Map<String, int> _statusCounts = {};
  AppointmentListStatus _status = AppointmentListStatus.initial;
  String? _error;

  List<Appointment> get appointments => _appointments;
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  List<Appointment> get appointmentHistory => _appointmentHistory;
  Map<String, int> get statusCounts => _statusCounts;
  AppointmentListStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == AppointmentListStatus.loading;

  Future<void> loadAppointments() async {
    _status = AppointmentListStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _repository.getAppointments();
      _upcomingAppointments = await _repository.getUpcomingAppointments();
      _appointmentHistory = await _repository.getAppointmentHistory();
      _statusCounts = await _repository.getStatusCounts();
      _status = AppointmentListStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AppointmentListStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshAppointments() async {
    try {
      _appointments = await _repository.getAppointments();
      _upcomingAppointments = await _repository.getUpcomingAppointments();
      _appointmentHistory = await _repository.getAppointmentHistory();
      _statusCounts = await _repository.getStatusCounts();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<Appointment?> getAppointmentById(String id) async {
    return await _repository.getAppointmentById(id);
  }

  Future<Appointment?> createAppointment({
    required String title,
    required String reason,
    required DateTime date,
    required String time,
    required String doctorName,
    required String type,
    required String clinic,
  }) async {
    try {
      final appointment = await _repository.createAppointment(
        title: title,
        reason: reason,
        date: date,
        time: time,
        doctorName: doctorName,
        type: type,
        clinic: clinic,
      );
      await refreshAppointments();
      return appointment;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<Appointment?> rescheduleAppointment(
      String id, DateTime newDate, String newTime) async {
    try {
      final appointment =
          await _repository.rescheduleAppointment(id, newDate, newTime);
      await refreshAppointments();
      return appointment;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<Appointment?> cancelAppointment(String id, {String? reason}) async {
    try {
      final appointment =
          await _repository.cancelAppointment(id, reason: reason);
      await refreshAppointments();
      return appointment;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  List<String> getAvailableTimeSlots() {
    return _repository.getAvailableTimeSlots();
  }

  List<String> getDoctorNames() {
    return _repository.getDoctorNames();
  }

  List<String> getAppointmentTypes() {
    return _repository.getAppointmentTypes();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
