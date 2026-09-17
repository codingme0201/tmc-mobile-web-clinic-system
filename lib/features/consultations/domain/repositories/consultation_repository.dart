import 'package:carelink_mobile/features/consultations/domain/models/consultation.dart';

abstract class ConsultationRepository {
  Future<List<Consultation>> getMyConsultations();
  Future<Consultation> getConsultationById(String id);
}
