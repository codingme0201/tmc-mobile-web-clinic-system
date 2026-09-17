import '../../domain/models/prescription.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_api_data_source.dart';

class PrescriptionApiRepository implements PrescriptionRepository {
  final PrescriptionApiDataSource _dataSource = PrescriptionApiDataSource();

  @override
  Future<List<Prescription>> getMyPrescriptions() async {
    return await _dataSource.getMyPrescriptions();
  }

  @override
  Future<Prescription> getPrescriptionById(String id) async {
    return await _dataSource.getPrescriptionById(id);
  }
}
