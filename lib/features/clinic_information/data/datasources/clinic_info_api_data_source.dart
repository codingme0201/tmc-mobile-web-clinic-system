import 'dart:convert';
import '../../../../core/utils/api_client.dart';
import '../../domain/models/clinic_information.dart';
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

    // 2. Doctor/nurse directory: public profile, background and schedule
    try {
      final staffResponse = await _apiClient.get('/me/clinic-staff');
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

    final fullData = Map<String, dynamic>.from(infoMap);
    fullData['staffSchedules'] = staffSchedules.map((s) => s.toJson()).toList();

    return ClinicInformation.fromJson(fullData);
  }
}
