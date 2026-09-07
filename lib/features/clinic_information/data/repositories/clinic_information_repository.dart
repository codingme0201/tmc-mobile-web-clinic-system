import '../datasources/mock_clinic_information_data_source.dart';

class ClinicInformationRepository {
  final MockClinicInformationDataSource _dataSource =
      MockClinicInformationDataSource.instance;

  Future<ClinicInformationData> getClinicInformation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dataSource.getData();
  }
}
