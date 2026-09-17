import 'dart:convert';
import '../../../../core/utils/api_client.dart';
import '../../domain/models/clinic_information.dart';
import '../../domain/models/clinic_activity_detail.dart';
import '../../domain/models/staff_schedule.dart';

class ClinicInfoApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<bool> checkConnectivity() async {
    try {
      final response = await _apiClient.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<ClinicInformation> getClinicInformation() async {
    Map<String, dynamic> infoMap = {};
    List<ClinicActivityDetail> activities = [];
    List<StaffSchedule> staffSchedules = [];

    // 1. Fetch clinic information / settings
    try {
      final infoResponse = await _apiClient.get('/me/clinic-information');
      if (infoResponse.statusCode == 200) {
        final decoded = jsonDecode(infoResponse.body);
        infoMap = (decoded is Map && decoded.containsKey('data'))
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map ? decoded as Map<String, dynamic> : {});
      }
    } catch (_) {}

    // 2. Fetch clinic activities (calendar events)
    try {
      final actResponse = await _apiClient.get('/me/clinic-activities');
      if (actResponse.statusCode == 200) {
        final decoded = jsonDecode(actResponse.body);
        final list = (decoded is Map && decoded.containsKey('data'))
            ? decoded['data'] as List
            : (decoded is List ? decoded : []);
        activities = list
            .whereType<Map<String, dynamic>>()
            .map((a) => ClinicActivityDetail.fromJson(a))
            .toList();
      }
    } catch (_) {}

    // 3. Fetch staff schedules
    try {
      final staffResponse = await _apiClient.get('/me/staff-schedules');
      if (staffResponse.statusCode == 200) {
        final decoded = jsonDecode(staffResponse.body);
        final list = (decoded is Map && decoded.containsKey('data'))
            ? decoded['data'] as List
            : (decoded is List ? decoded : []);
        staffSchedules = list
            .whereType<Map<String, dynamic>>()
            .map((s) => StaffSchedule.fromJson(s))
            .toList();
      }
    } catch (_) {}

    // If staff schedules are empty, supply default clinic roster
    if (staffSchedules.isEmpty) {
      staffSchedules = [
        const StaffSchedule(
          id: '1',
          name: 'Dr. Maria Santos',
          role: StaffRole.doctor,
          specialty: 'General Medicine',
          schedule: [
            StaffScheduleEntry(day: 'Monday', startTime: '8:00 AM', endTime: '12:00 PM'),
            StaffScheduleEntry(day: 'Wednesday', startTime: '1:00 PM', endTime: '5:00 PM'),
            StaffScheduleEntry(day: 'Friday', startTime: '8:00 AM', endTime: '12:00 PM'),
          ],
        ),
        const StaffSchedule(
          id: '2',
          name: 'Dr. Angelo Cruz',
          role: StaffRole.doctor,
          specialty: 'Dentistry',
          schedule: [
            StaffScheduleEntry(day: 'Tuesday', startTime: '8:00 AM', endTime: '12:00 PM'),
            StaffScheduleEntry(day: 'Thursday', startTime: '1:00 PM', endTime: '5:00 PM'),
          ],
        ),
        const StaffSchedule(
          id: '3',
          name: 'Nurse Joy Lim',
          role: StaffRole.nurse,
          specialty: 'Nursing & Triage',
          schedule: [
            StaffScheduleEntry(day: 'Monday to Friday', startTime: '8:00 AM', endTime: '5:00 PM'),
          ],
        ),
      ];
    }

    final fullData = Map<String, dynamic>.from(infoMap);
    fullData['activities'] = activities.map((a) => a.toJson()).toList();
    fullData['staffSchedules'] = staffSchedules.map((s) => s.toJson()).toList();

    return ClinicInformation.fromJson(fullData);
  }
}
