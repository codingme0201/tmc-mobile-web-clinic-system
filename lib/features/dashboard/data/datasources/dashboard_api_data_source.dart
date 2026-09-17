import 'dart:convert';
import '../../../../core/utils/api_client.dart';

class DashboardApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final results = await Future.wait([
      _apiClient.get('/me/profile'),
      _apiClient.get('/me/appointments'),
      _apiClient.get('/me/consultations'),
      _apiClient.get('/me/medical-records'),
      _apiClient.get('/me/clinic-activities'),
    ]);

    final profileRes = results[0];
    final appRes = results[1];
    final consRes = results[2];
    final mrRes = results[3];
    final actRes = results[4];

    dynamic profileData;
    if (profileRes.statusCode == 200) {
      final decoded = jsonDecode(profileRes.body);
      profileData = decoded is Map && decoded['data'] != null ? decoded['data'] : decoded;
    }

    List<dynamic> appData = [];
    if (appRes.statusCode == 200) {
      final decoded = jsonDecode(appRes.body);
      appData = decoded is Map && decoded['data'] != null ? decoded['data'] : (decoded is List ? decoded : []);
    }

    List<dynamic> consData = [];
    if (consRes.statusCode == 200) {
      final decoded = jsonDecode(consRes.body);
      consData = decoded is Map && decoded['data'] != null ? decoded['data'] : (decoded is List ? decoded : []);
    }

    dynamic mrData;
    if (mrRes.statusCode == 200) {
      final decoded = jsonDecode(mrRes.body);
      mrData = decoded is Map && decoded['data'] != null ? decoded['data'] : decoded;
    }

    List<dynamic> actData = [];
    if (actRes.statusCode == 200) {
      final decoded = jsonDecode(actRes.body);
      actData = decoded is Map && decoded['data'] != null ? decoded['data'] : (decoded is List ? decoded : []);
    }

    return {
      'user': profileData,
      'appointments': appData,
      'consultations': consData,
      'medicalRecord': mrData,
      'clinicActivities': actData,
    };
  }
}
