import '../../domain/models/clinic_information.dart';
import '../../domain/repositories/clinic_information_repository.dart';
import '../datasources/mock_clinic_information_data_source.dart';

class MockClinicInformationRepository implements ClinicInformationRepository {
  final MockClinicInformationDataSource _dataSource =
      MockClinicInformationDataSource.instance;

  @override
  Future<ClinicInformation> getClinicInformation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataSource.getClinicInformation();
  }

  @override
  Future<bool> checkSystemStatus() async {
    return true;
  }
}
