import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';
import '../../domain/models/prescription.dart';

class PrescriptionApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Prescription>> getMyPrescriptions() async {
    final response = await _apiClient.get('/me/prescriptions');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = (decoded is Map && decoded.containsKey('data'))
          ? decoded['data'] as List
          : (decoded is List ? decoded : []);

      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => Prescription.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load prescriptions: ${response.statusCode}');
    }
  }

  Future<Prescription> getPrescriptionById(String id) async {
    final response = await _apiClient.get('/me/prescriptions/$id');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = (decoded is Map && decoded.containsKey('data'))
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;
      return Prescription.fromJson(data);
    } else {
      throw Exception('Failed to load prescription detail: ${response.statusCode}');
    }
  }
}
