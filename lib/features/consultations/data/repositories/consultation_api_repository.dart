import 'package:carelink_mobile/features/consultations/domain/models/consultation.dart';
import 'package:carelink_mobile/features/consultations/domain/repositories/consultation_repository.dart';
import 'package:carelink_mobile/features/consultations/data/datasources/consultation_api_data_source.dart';

class ConsultationApiRepository implements ConsultationRepository {
  final ConsultationApiDataSource _dataSource = ConsultationApiDataSource();

  @override
  Future<List<Consultation>> getMyConsultations() async {
    final data = await _dataSource.getMyConsultations();
    return data.map((json) => Consultation.fromJson(json)).toList();
  }

  @override
  Future<Consultation> getConsultationById(String id) async {
    final data = await _dataSource.getConsultationById(id);
    return Consultation.fromJson(data);
  }
}
