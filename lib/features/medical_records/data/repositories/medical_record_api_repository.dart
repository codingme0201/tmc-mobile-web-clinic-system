import 'package:carelink_mobile/features/medical_records/domain/models/medical_record.dart';
import 'package:carelink_mobile/features/medical_records/domain/repositories/medical_record_repository.dart';
import 'package:carelink_mobile/features/medical_records/data/datasources/medical_record_api_data_source.dart';

class MedicalRecordApiRepository implements MedicalRecordRepository {
  final MedicalRecordApiDataSource _dataSource = MedicalRecordApiDataSource();

  @override
  Future<MedicalRecord?> getMyMedicalRecord() async {
    final data = await _dataSource.getMyMedicalRecord();
    if (data == null) return null;
    return MedicalRecord.fromJson(data);
  }
}
