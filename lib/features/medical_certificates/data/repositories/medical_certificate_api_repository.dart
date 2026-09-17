import '../../domain/models/medical_certificate.dart';
import '../../domain/repositories/medical_certificate_repository.dart';
import '../datasources/medical_certificate_api_data_source.dart';

class MedicalCertificateApiRepository implements MedicalCertificateRepository {
  final MedicalCertificateApiDataSource _dataSource = MedicalCertificateApiDataSource();

  @override
  Future<List<MedicalCertificate>> getMyCertificates() async {
    return await _dataSource.getMyCertificates();
  }

  @override
  Future<MedicalCertificate> requestCertificate({
    required String purpose,
    String? diagnosis,
    String? consultationId,
  }) async {
    return await _dataSource.requestCertificate(
      purpose: purpose,
      diagnosis: diagnosis,
      consultationId: consultationId,
    );
  }
}
