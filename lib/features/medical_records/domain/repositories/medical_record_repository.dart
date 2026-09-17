import 'package:carelink_mobile/features/medical_records/domain/models/medical_record.dart';

abstract class MedicalRecordRepository {
  Future<MedicalRecord?> getMyMedicalRecord();
}
