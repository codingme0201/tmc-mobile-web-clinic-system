import 'package:carelink_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:carelink_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:carelink_mobile/features/dashboard/data/datasources/dashboard_api_data_source.dart';
import 'package:carelink_mobile/core/models/appointment.dart';
import 'package:carelink_mobile/core/models/consultation.dart';
import 'package:carelink_mobile/core/models/medical_record.dart';
import 'package:carelink_mobile/core/models/clinic_activity.dart';
import 'package:carelink_mobile/core/models/schedule_item.dart';

class DashboardApiRepository implements DashboardRepository {
  final DashboardApiDataSource _dataSource = DashboardApiDataSource();

  @override
  Future<DashboardData> getDashboardData() async {
    final summary = await _dataSource.getDashboardSummary();

    // Map appointments
    final appointmentsRaw = summary['appointments'] as List? ?? [];
    final appointments = appointmentsRaw
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();

    // Map consultations
    final consultationsRaw = summary['consultations'] as List? ?? [];
    final consultations = consultationsRaw
        .map((json) => Consultation.fromJson(json as Map<String, dynamic>))
        .toList();

    // Map medical records
    final List<MedicalRecord> medicalRecords = [];
    if (summary['medicalRecord'] is Map<String, dynamic>) {
      final mr = summary['medicalRecord'] as Map<String, dynamic>;
      medicalRecords.add(MedicalRecord.fromJson(mr));

      // Also extract histories as items if available
      if (mr['medicalHistory'] is List) {
        for (var h in mr['medicalHistory']) {
          if (h is Map<String, dynamic>) {
            medicalRecords.add(MedicalRecord(
              id: h['id']?.toString() ?? '',
              title: h['condition']?.toString() ?? 'Medical History',
              date: DateTime.tryParse(h['date']?.toString() ?? '') ?? DateTime.now(),
              type: 'History',
              summary: h['notes']?.toString(),
            ));
          }
        }
      }
    }

    // Map clinic activities
    final activitiesRaw = summary['clinicActivities'] as List? ?? [];
    final clinicActivities = activitiesRaw
        .map((json) => ClinicActivity.fromJson(json as Map<String, dynamic>))
        .toList();

    // Construct upcoming schedule from upcoming appointments and clinic activities
    final List<ScheduleItem> upcomingSchedule = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var app in appointments) {
      final aDate = DateTime(app.date.year, app.date.month, app.date.day);
      if (!aDate.isBefore(today) &&
          app.status != AppointmentStatus.completed &&
          app.status != AppointmentStatus.cancelled) {
        upcomingSchedule.add(ScheduleItem(
          id: 'app-${app.id}',
          title: '${app.type}: ${app.doctorName}',
          date: app.date,
          time: app.time,
          type: ScheduleType.appointment,
          description: app.reason,
        ));
      }
    }

    for (var act in clinicActivities) {
      final actDate = DateTime(act.date.year, act.date.month, act.date.day);
      if (!actDate.isBefore(today)) {
        upcomingSchedule.add(ScheduleItem(
          id: 'act-${act.id}',
          title: act.title,
          date: act.date,
          type: ScheduleType.clinicActivity,
          description: act.description,
        ));
      }
    }

    upcomingSchedule.sort((a, b) => a.date.compareTo(b.date));

    return DashboardData(
      appointments: appointments,
      consultations: consultations,
      medicalRecords: medicalRecords,
      clinicActivities: clinicActivities,
      upcomingSchedule: upcomingSchedule,
    );
  }
}
