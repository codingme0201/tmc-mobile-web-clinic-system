import '../../../../core/models/appointment.dart';
import '../../../../core/models/consultation.dart';
import '../../../../core/models/medical_record.dart';
import '../../../../core/models/clinic_activity.dart';
import '../../../../core/models/schedule_item.dart';

class DashboardData {
  final List<Appointment> appointments;
  final List<Consultation> consultations;
  final List<MedicalRecord> medicalRecords;
  final List<ClinicActivity> clinicActivities;
  final List<ScheduleItem> upcomingSchedule;

  const DashboardData({
    required this.appointments,
    required this.consultations,
    required this.medicalRecords,
    required this.clinicActivities,
    required this.upcomingSchedule,
  });
}

class MockDashboardDataSource {
  static final MockDashboardDataSource instance = MockDashboardDataSource._();
  MockDashboardDataSource._();

  DashboardData getDashboardData() {
    final now = DateTime.now();

    final appointments = [
      Appointment(
        id: 'apt-1',
        title: 'General Checkup',
        reason: 'Annual physical examination',
        date: now.add(const Duration(days: 3)),
        time: '10:00 AM',
        status: AppointmentStatus.confirmed,
        doctorName: 'Dr. Reyes',
        type: 'Check-up',
        clinic: 'TMC Student Health Clinic',
        requestedOn: now.subtract(const Duration(days: 5)),
      ),
      Appointment(
        id: 'apt-2',
        title: 'Dental Consultation',
        reason: 'Routine dental cleaning',
        date: now.add(const Duration(days: 7)),
        time: '2:30 PM',
        status: AppointmentStatus.pending,
        doctorName: 'Dr. Cruz',
        type: 'Dental',
        clinic: 'TMC Dental Clinic',
        requestedOn: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: 'apt-3',
        title: 'Follow-up Visit',
        reason: 'Post-lab results review',
        date: now.subtract(const Duration(days: 5)),
        time: '9:00 AM',
        status: AppointmentStatus.completed,
        doctorName: 'Dr. Santos',
        type: 'Follow-up',
        clinic: 'TMC Student Health Clinic',
        notes: 'Patient responded well to treatment.',
        requestedOn: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Appointment(
        id: 'apt-4',
        title: 'Eye Examination',
        reason: 'Vision check',
        date: now.subtract(const Duration(days: 14)),
        time: '11:00 AM',
        status: AppointmentStatus.cancelled,
        doctorName: 'Dr. Lim',
        type: 'Vision',
        clinic: 'TMC Eye Clinic',
        cancelReason: 'Schedule conflict',
        requestedOn: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Appointment(
        id: 'apt-5',
        title: 'Vaccination',
        reason: 'Flu vaccine',
        date: now.subtract(const Duration(days: 20)),
        time: '3:00 PM',
        status: AppointmentStatus.completed,
        doctorName: 'Dr. Reyes',
        type: 'Vaccination',
        clinic: 'TMC Student Health Clinic',
        notes: 'Influenza vaccine administered.',
        requestedOn: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      Appointment(
        id: 'apt-6',
        title: 'Lab Test',
        reason: 'Blood work and urinalysis',
        date: now.add(const Duration(days: 10)),
        time: '8:30 AM',
        status: AppointmentStatus.pending,
        doctorName: 'Dr. Santos',
        type: 'Laboratory',
        clinic: 'TMC Laboratory',
        requestedOn: now.subtract(const Duration(days: 1)),
      ),
    ];

    final consultations = [
      Consultation(
        id: 'con-1',
        title: 'General Consultation',
        doctorName: 'Dr. Reyes',
        date: now.subtract(const Duration(days: 5)),
        time: '9:00 AM',
        status: ConsultationStatus.completed,
        diagnosis: 'General wellness check - no issues found',
      ),
      Consultation(
        id: 'con-2',
        title: 'Dental Checkup',
        doctorName: 'Dr. Cruz',
        date: now.add(const Duration(days: 7)),
        time: '2:30 PM',
        status: ConsultationStatus.scheduled,
      ),
      Consultation(
        id: 'con-3',
        title: 'Vaccination Consultation',
        doctorName: 'Dr. Reyes',
        date: now.subtract(const Duration(days: 20)),
        time: '3:00 PM',
        status: ConsultationStatus.completed,
        diagnosis: 'Flu vaccination administered',
      ),
      Consultation(
        id: 'con-4',
        title: 'Lab Results Review',
        doctorName: 'Dr. Santos',
        date: now.add(const Duration(days: 3)),
        time: '10:00 AM',
        status: ConsultationStatus.scheduled,
      ),
    ];

    final medicalRecords = [
      MedicalRecord(
        id: 'mr-1',
        title: 'General Checkup Results',
        date: now.subtract(const Duration(days: 5)),
        type: 'Consultation',
        summary: 'All vitals normal. No concerns noted.',
      ),
      MedicalRecord(
        id: 'mr-2',
        title: 'Blood Work Results',
        date: now.subtract(const Duration(days: 30)),
        type: 'Laboratory',
        summary: 'Complete blood count within normal range.',
      ),
      MedicalRecord(
        id: 'mr-3',
        title: 'Vaccination Record',
        date: now.subtract(const Duration(days: 20)),
        type: 'Vaccination',
        summary: 'Influenza vaccine administered.',
      ),
    ];

    final clinicActivities = [
      ClinicActivity(
        id: 'ca-1',
        title: 'Flu Vaccination Drive',
        description: 'Free flu vaccines available for all enrolled students this week.',
        date: now.add(const Duration(days: 1)),
        type: 'Health Program',
      ),
      ClinicActivity(
        id: 'ca-2',
        title: 'Clinic Schedule Update',
        description: 'Extended clinic hours on Fridays starting next month.',
        date: now.add(const Duration(days: 5)),
        type: 'Announcement',
      ),
      ClinicActivity(
        id: 'ca-3',
        title: 'Health Awareness Seminar',
        description: 'Mental health awareness session for students.',
        date: now.add(const Duration(days: 12)),
        type: 'Event',
      ),
    ];

    final upcomingSchedule = [
      ScheduleItem(
        id: 'sch-1',
        title: 'General Checkup',
        date: now.add(const Duration(days: 3)),
        time: '10:00 AM',
        type: ScheduleType.appointment,
        description: 'Dr. Reyes',
      ),
      ScheduleItem(
        id: 'sch-2',
        title: 'Flu Vaccination Drive',
        date: now.add(const Duration(days: 1)),
        type: ScheduleType.clinicActivity,
        description: 'Free flu vaccines',
      ),
      ScheduleItem(
        id: 'sch-3',
        title: 'Dental Consultation',
        date: now.add(const Duration(days: 7)),
        time: '2:30 PM',
        type: ScheduleType.appointment,
        description: 'Dr. Cruz',
      ),
      ScheduleItem(
        id: 'sch-4',
        title: 'Clinic Schedule Update',
        date: now.add(const Duration(days: 5)),
        type: ScheduleType.clinicSchedule,
        description: 'Extended hours on Fridays',
      ),
      ScheduleItem(
        id: 'sch-5',
        title: 'Lab Test',
        date: now.add(const Duration(days: 10)),
        time: '8:30 AM',
        type: ScheduleType.appointment,
        description: 'Dr. Santos',
      ),
    ];

    return DashboardData(
      appointments: appointments,
      consultations: consultations,
      medicalRecords: medicalRecords,
      clinicActivities: clinicActivities,
      upcomingSchedule: upcomingSchedule,
    );
  }
}
