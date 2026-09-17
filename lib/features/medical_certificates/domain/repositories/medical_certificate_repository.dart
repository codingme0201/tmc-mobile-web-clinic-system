import '../models/medical_certificate.dart';

abstract class MedicalCertificateRepository {
  Future<List<MedicalCertificate>> getMyCertificates();
  Future<MedicalCertificate> requestCertificate({
    required String purpose,
    String? diagnosis,
    String? consultationId,
  });
}
