import '../../domain/models/profile.dart';

class MockProfileDataSource {
  static final MockProfileDataSource instance = MockProfileDataSource._();
  MockProfileDataSource._();

  Profile? _profile;

  Profile getProfile(String userId) {
    _profile ??= Profile(
      id: userId,
      name: 'Maria Santos',
      email: 'maria.santos@tmc.edu.ph',
      phone: '+63 917 123 4567',
      telephone: '+63 (02) 8123-4567',
      address: 'Tagum Norte, Trinidad, Bohol, Philippines',
      dateOfBirth: DateTime(2003, 6, 15),
      gender: 'Female',
      accountStatus: AccountStatus.active,
      studentInfo: const StudentInfo(
        studentId: '24-021128',
        program: 'Bachelor of Science in Information Technology',
        yearLevel: '3rd Year',
        block: 'Block 1',
        enrollmentStatus: 'Enrolled',
      ),
      medicalInfo: const MedicalInfo(
        bloodType: 'O+',
        allergies: 'Penicillin',
        conditions: 'None',
        medications: 'None',
        emergencyContact: 'Juan Santos',
        emergencyContactNumber: '+63 917 987 6543',
      ),
    );
    return _profile!;
  }

  Profile updateProfile(Profile updated) {
    _profile = updated;
    return _profile!;
  }
}
