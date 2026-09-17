import '../../domain/models/clinic_information.dart';
import '../../domain/repositories/clinic_information_repository.dart';
import '../datasources/clinic_info_api_data_source.dart';

class ClinicInfoApiRepository implements ClinicInformationRepository {
  final ClinicInfoApiDataSource _dataSource = ClinicInfoApiDataSource();

  @override
  Future<ClinicInformation> getClinicInformation() async {
    return await _dataSource.getClinicInformation();
  }

  @override
  Future<bool> checkSystemStatus() async {
    return await _dataSource.checkConnectivity();
  }
}
