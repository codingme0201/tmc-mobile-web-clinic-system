import '../../../../core/models/appointment.dart';

class MockAppointmentDataSource {
  static final MockAppointmentDataSource instance =
      MockAppointmentDataSource._();
  MockAppointmentDataSource._();

  final List<Appointment> _appointments = [];

  MockAppointmentDataSource() {
    _initializeAppointments();
  }

  void _initializeAppointments() {
    final now = DateTime.now();

    _appointments.addAll([
      Appointment(
        id: 'apt-001',
        title: 'General Checkup',
        reason: 'Annual physical examination',
        date: now.add(const Duration(days: 3)),
        time: '10:00 AM',
        status: AppointmentStatus.confirmed,
        doctorName: 'Dr. Maria Santos',
        type: 'Check-up',
        clinic: 'TMC Student Health Clinic',
        requestedOn: now.subtract(const Duration(days: 5)),
      ),
      Appointment(
        id: 'apt-002',
        title: 'Dental Consultation',
        reason: 'Routine dental cleaning and checkup',
        date: now.add(const Duration(days: 7)),
        time: '2:30 PM',
        status: AppointmentStatus.pending,
        doctorName: 'Dr. Angelo Cruz',
        type: 'Dental',
        clinic: 'TMC Dental Clinic',
        requestedOn: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: 'apt-003',
        title: 'Follow-up Visit',
        reason: 'Post-lab results review and medication adjustment',
        date: now.subtract(const Duration(days: 5)),
        time: '9:00 AM',
        status: AppointmentStatus.completed,
        doctorName: 'Dr. Elena Reyes',
        type: 'Follow-up',
        clinic: 'TMC Student Health Clinic',
        notes: 'Patient responded well to medication. Continue current prescription.',
        requestedOn: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Appointment(
        id: 'apt-004',
        title: 'Eye Examination',
        reason: 'Vision check for new glasses prescription',
        date: now.subtract(const Duration(days: 14)),
        time: '11:00 AM',
        status: AppointmentStatus.cancelled,
        doctorName: 'Dr. Ana Lim',
        type: 'Vision',
        clinic: 'TMC Eye Clinic',
        cancelReason: 'Schedule conflict - patient requested reschedule',
        requestedOn: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Appointment(
        id: 'apt-005',
        title: 'Vaccination',
        reason: 'Flu vaccine for the semester',
        date: now.subtract(const Duration(days: 20)),
        time: '3:00 PM',
        status: AppointmentStatus.completed,
        doctorName: 'Dr. Maria Santos',
        type: 'Vaccination',
        clinic: 'TMC Student Health Clinic',
        notes: 'Influenza vaccine administered. No adverse reactions observed.',
        requestedOn: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      Appointment(
        id: 'apt-006',
        title: 'Lab Test',
        reason: 'Blood work and urinalysis for annual health screening',
        date: now.add(const Duration(days: 10)),
        time: '8:30 AM',
        status: AppointmentStatus.pending,
        doctorName: 'Dr. Roberto Santos',
        type: 'Laboratory',
        clinic: 'TMC Laboratory',
        requestedOn: now.subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: 'apt-007',
        title: 'Mental Health Consultation',
        reason: 'Stress management and wellness check',
        date: now.subtract(const Duration(days: 30)),
        time: '1:00 PM',
        status: AppointmentStatus.completed,
        doctorName: 'Dr. Camille Fernandez',
        type: 'Mental Health',
        clinic: 'TMC Wellness Center',
        notes: 'Session completed. Recommended follow-up in 2 weeks.',
        requestedOn: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Appointment(
        id: 'apt-008',
        title: 'Dental Cleaning',
        reason: 'Semi-annual dental prophylaxis',
        date: now.subtract(const Duration(days: 45)),
        time: '10:30 AM',
        status: AppointmentStatus.noShow,
        doctorName: 'Dr. Angelo Cruz',
        type: 'Dental',
        clinic: 'TMC Dental Clinic',
        requestedOn: now.subtract(const Duration(days: 50)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
      Appointment(
        id: 'apt-009',
        title: 'Allergy Consultation',
        reason: 'Persistent allergic rhinitis - need medication review',
        date: now.add(const Duration(days: 14)),
        time: '9:30 AM',
        status: AppointmentStatus.confirmed,
        doctorName: 'Dr. Elena Reyes',
        type: 'Check-up',
        clinic: 'TMC Student Health Clinic',
        requestedOn: now.subtract(const Duration(days: 3)),
      ),
      Appointment(
        id: 'apt-010',
        title: 'Physical Therapy Assessment',
        reason: 'Knee pain after sports injury',
        date: now.subtract(const Duration(days: 7)),
        time: '2:00 PM',
        status: AppointmentStatus.cancelled,
        doctorName: 'Dr. Marco Rivera',
        type: 'Therapy',
        clinic: 'TMC Rehabilitation Center',
        cancelReason: 'Clinic temporarily closed for maintenance',
        requestedOn: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
    ]);
  }

  List<Appointment> getAppointments() {
    return List.unmodifiable(_appointments);
  }

  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((a) =>
            a.date.isAfter(now) ||
            (a.date.year == now.year &&
                a.date.month == now.month &&
                a.date.day == now.day))
        .where((a) =>
            a.status == AppointmentStatus.pending ||
            a.status == AppointmentStatus.confirmed)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> getAppointmentHistory() {
    final now = DateTime.now();
    return _appointments
        .where((a) =>
            a.date.isBefore(now) &&
            (a.status == AppointmentStatus.completed ||
                a.status == AppointmentStatus.cancelled ||
                a.status == AppointmentStatus.noShow))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, int> getStatusCounts() {
    final counts = <String, int>{};
    for (final status in AppointmentStatus.values) {
      counts[status.name] =
          _appointments.where((a) => a.status == status).length;
    }
    return counts;
  }

  Appointment createAppointment({
    required String title,
    required String reason,
    required DateTime date,
    required String time,
    required String doctorName,
    required String type,
    required String clinic,
  }) {
    final now = DateTime.now();
    final newAppointment = Appointment(
      id: 'apt-${_appointments.length + 1}',
      title: title,
      reason: reason,
      date: date,
      time: time,
      status: AppointmentStatus.pending,
      doctorName: doctorName,
      type: type,
      clinic: clinic,
      requestedOn: now,
    );
    _appointments.add(newAppointment);
    return newAppointment;
  }

  Appointment? rescheduleAppointment(
      String id, DateTime newDate, String newTime) {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) return null;

    final appointment = _appointments[index];
    if (appointment.status != AppointmentStatus.pending &&
        appointment.status != AppointmentStatus.confirmed) {
      return null;
    }

    final updated = appointment.copyWith(
      date: newDate,
      time: newTime,
      updatedAt: DateTime.now(),
    );
    _appointments[index] = updated;
    return updated;
  }

  Appointment? cancelAppointment(String id, {String? reason}) {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) return null;

    final appointment = _appointments[index];
    if (appointment.status == AppointmentStatus.completed ||
        appointment.status == AppointmentStatus.cancelled) {
      return null;
    }

    final updated = appointment.copyWith(
      status: AppointmentStatus.cancelled,
      cancelReason: reason,
      updatedAt: DateTime.now(),
    );
    _appointments[index] = updated;
    return updated;
  }

  List<String> getAvailableTimeSlots() {
    return [
      '8:00 AM',
      '8:30 AM',
      '9:00 AM',
      '9:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
      '1:00 PM',
      '1:30 PM',
      '2:00 PM',
      '2:30 PM',
      '3:00 PM',
      '3:30 PM',
      '4:00 PM',
      '4:30 PM',
    ];
  }

  List<String> getDoctorNames() {
    return [
      'Dr. Maria Santos',
      'Dr. Angelo Cruz',
      'Dr. Elena Reyes',
      'Dr. Ana Lim',
      'Dr. Roberto Santos',
      'Dr. Camille Fernandez',
      'Dr. Marco Rivera',
    ];
  }

  List<String> getAppointmentTypes() {
    return [
      'Check-up',
      'Dental',
      'Vision',
      'Vaccination',
      'Laboratory',
      'Follow-up',
      'Mental Health',
      'Therapy',
      'Emergency',
    ];
  }
}
