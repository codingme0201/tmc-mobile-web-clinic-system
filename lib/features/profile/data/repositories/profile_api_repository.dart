import 'package:carelink_mobile/features/profile/domain/models/profile.dart';
import 'package:carelink_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:carelink_mobile/features/profile/data/datasources/profile_api_data_source.dart';

class ProfileApiRepository implements ProfileRepository {
  final ProfileApiDataSource _dataSource = ProfileApiDataSource();

  @override
  Future<Profile> getProfile(String userId) async {
    return await _dataSource.getProfile();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    return await _dataSource.updateProfile(profile);
  }
}
