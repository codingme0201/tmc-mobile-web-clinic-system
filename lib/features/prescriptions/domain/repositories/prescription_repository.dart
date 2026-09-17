import '../models/prescription.dart';

abstract class PrescriptionRepository {
  Future<List<Prescription>> getMyPrescriptions();
  Future<Prescription> getPrescriptionById(String id);
}
