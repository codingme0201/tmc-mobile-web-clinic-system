import 'package:carelink_mobile/core/models/appointment.dart';
import 'package:carelink_mobile/core/models/consultation.dart';
import 'package:carelink_mobile/core/models/medical_record.dart';
import 'package:carelink_mobile/core/models/clinic_activity.dart';
import 'package:carelink_mobile/core/models/schedule_item.dart';

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
