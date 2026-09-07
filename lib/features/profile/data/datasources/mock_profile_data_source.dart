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
      address: '123 Rizal Avenue, Quezon City',
      dateOfBirth: DateTime(2003, 6, 15),
      gender: 'Female',
      accountStatus: AccountStatus.active,
      studentInfo: const StudentInfo(
        studentId: 'STU-2024-00156',
        program: 'Bachelor of Science in Nursing',
        yearLevel: '3rd Year',
        section: 'Section A',
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
