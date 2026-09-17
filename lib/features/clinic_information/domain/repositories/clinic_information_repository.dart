import '../models/clinic_information.dart';

abstract class ClinicInformationRepository {
  Future<ClinicInformation> getClinicInformation();
  Future<bool> checkSystemStatus();
}
