import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';

class ConsultationApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getMyConsultations() async {
    final response = await _apiClient.get('/me/consultations');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['data'] != null) {
        return decoded['data'] as List<dynamic>;
      }
      if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception('Failed to load consultations: ${response.statusCode}');
    }
  }

  Future<dynamic> getConsultationById(String id) async {
    final response = await _apiClient.get('/me/consultations/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map && data['data'] != null ? data['data'] : data;
    } else {
      throw Exception('Failed to load consultation details: ${response.statusCode}');
    }
  }
}
