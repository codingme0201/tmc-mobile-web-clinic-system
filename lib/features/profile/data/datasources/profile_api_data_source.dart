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

      return Profile(
        id: p['id'].toString(),
        name: (p['name'] ?? '').toString(),
        email: userEmail.isNotEmpty ? userEmail : 'patient@tmccarelink.com',
        phone: (p['contact'] ?? '+63 912 345 6789').toString(),
        telephone: (p['telephone'] ?? '+63 (02) 8123-4567').toString(),
        address: (p['address'] ?? 'Health Sciences Bldg, Main Campus, Trinidad, Bohol').toString(),
        dateOfBirth: DateTime(2003, 5, 15),
        accountStatus: AccountStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == (p['status'] ?? '').toString().toLowerCase(),
          orElse: () => AccountStatus.active,
        ),
        studentInfo: StudentInfo(
          studentId: (p['patientId'] ?? '24-021128').toString(),
          program: (p['courseDept'] ?? 'Bachelor of Science in Information Technology').toString(),
          yearLevel: '3rd Year',
          block: (p['block'] ?? 'Block 1').toString(),
          enrollmentStatus: 'Enrolled',
        ),
        medicalInfo: MedicalInfo(
          bloodType: (p['bloodType'] ?? 'O+').toString(),
          allergies: (p['allergies'] ?? 'None').toString(),
          conditions: (p['history'] ?? 'None').toString(),
          emergencyContact: (p['emergencyContact'] ?? '').toString(),
          emergencyContactNumber: (p['contact'] ?? '+63 912 345 6789').toString(),
        ),
      );
    } else {
      throw Exception('Failed to load profile: ${profileRes.statusCode}');
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    final response = await _apiClient.put('/me/profile', body: {
      'contact': profile.phone ?? profile.medicalInfo?.emergencyContactNumber ?? '',
      'emergencyContact': profile.medicalInfo?.emergencyContact ?? '',
    });

    if (response.statusCode == 200) {
      return getProfile();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }
}
