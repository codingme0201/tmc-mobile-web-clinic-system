import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';
import '../../domain/models/medical_certificate.dart';

class MedicalCertificateApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<MedicalCertificate>> getMyCertificates() async {
    final response = await _apiClient.get('/me/medical-certificates');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = (decoded is Map && decoded.containsKey('data'))
          ? decoded['data'] as List
          : (decoded is List ? decoded : []);

      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => MedicalCertificate.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load medical certificates: ${response.statusCode}');
    }
  }

  Future<MedicalCertificate> requestCertificate({
    required String purpose,
    String? diagnosis,
    String? consultationId,
  }) async {
    final response = await _apiClient.post(
      '/me/medical-certificates',
      body: {
        'purpose': purpose,
        if (diagnosis != null && diagnosis.isNotEmpty) 'diagnosis': diagnosis,
        if (consultationId != null && consultationId.isNotEmpty)
          'consultationId': consultationId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = (decoded is Map && decoded.containsKey('data'))
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;
      return MedicalCertificate.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to request medical certificate.');
    }
  }
}
