import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';
import 'package:carelink_mobile/features/profile/domain/models/profile.dart';

class ProfileApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Profile> getProfile() async {
    final responses = await Future.wait([
      _apiClient.get('/me/profile'),
      _apiClient.get('/user'),
    ]);

    final profileRes = responses[0];
    final userRes = responses[1];

    if (profileRes.statusCode == 200) {
      final data = jsonDecode(profileRes.body);
      final p = data['data'];

      String userEmail = '';
      if (userRes.statusCode == 200) {
        final userData = jsonDecode(userRes.body);
        if (userData['user'] != null && userData['user']['email'] != null) {
          userEmail = userData['user']['email'].toString();
        }
      }

      String? text(dynamic value) {
        final str = (value ?? '').toString().trim();
        return str.isEmpty ? null : str;
      }

      return Profile(
        id: p['id'].toString(),
        name: (p['name'] ?? '').toString(),
        email: userEmail,
        phone: text(p['contact']),
        address: text(p['address']),
        age: p['age'] is int ? p['age'] as int : int.tryParse('${p['age'] ?? ''}'),
        accountStatus: AccountStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == (p['status'] ?? '').toString().toLowerCase(),
          orElse: () => AccountStatus.active,
        ),
        studentInfo: StudentInfo(
          studentId: (p['patientId'] ?? '').toString(),
          program: (p['courseDept'] ?? '').toString(),
          yearLevel: '',
          block: (p['block'] ?? '').toString(),
          enrollmentStatus: '',
        ),
        medicalInfo: MedicalInfo(
          bloodType: '',
          allergies: text(p['allergies']) ?? 'None',
          conditions: text(p['history']) ?? 'None',
          emergencyContact: text(p['emergencyContactName']) ?? text(p['emergencyContact']),
          emergencyContactNumber: text(p['emergencyContactPhone']),
        ),
      );
    } else {
      throw Exception('Failed to load profile: ${profileRes.statusCode}');
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    final response = await _apiClient.put('/me/profile', body: {
      'contact': profile.phone ?? '',
      'address': profile.address ?? '',
    });

    if (response.statusCode == 200) {
      return getProfile();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }
}
