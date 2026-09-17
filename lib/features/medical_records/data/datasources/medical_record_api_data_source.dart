import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';

class MedicalRecordApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getMyMedicalRecord() async {
    final response = await _apiClient.get('/me/medical-records');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as Map<String, dynamic>?;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load medical record: ${response.statusCode}');
    }
  }
}
