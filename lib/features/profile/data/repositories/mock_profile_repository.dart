import '../../domain/models/profile.dart';
import '../datasources/mock_profile_data_source.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  final MockProfileDataSource _dataSource = MockProfileDataSource.instance;

  @override
  Future<Profile> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataSource.getProfile(userId);
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _dataSource.updateProfile(profile);
  }
}
