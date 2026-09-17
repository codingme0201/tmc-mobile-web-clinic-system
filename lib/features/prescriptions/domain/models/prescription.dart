import 'package:meta/meta.dart';

@immutable
class PrescriptionMedicationItem {
  final String id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  const PrescriptionMedicationItem({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });

  factory PrescriptionMedicationItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicationItem(
      id: json['id']?.toString() ?? '',
      medicineName: (json['medicineName'] ?? json['medicine_name'] ?? json['name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      frequency: (json['frequency'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      instructions: (json['instructions'] ?? '').toString(),
    );
  }
}

@immutable
class Prescription {
  final String id;
  final String reference;
  final String patient;
  final String patientId;
  final String? consultationId;
  final String prescribedBy;
  final String date;
  final List<PrescriptionMedicationItem> medications;

  const Prescription({
    required this.id,
    required this.reference,
    required this.patient,
    required this.patientId,
    this.consultationId,
    required this.prescribedBy,
    required this.date,
    required this.medications,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    final medsRaw = json['medications'] as List? ?? [];
    return Prescription(
      id: json['id']?.toString() ?? '',
      reference: (json['reference'] ?? '').toString(),
      patient: (json['patient'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      consultationId: json['consultationId']?.toString(),
      prescribedBy: (json['prescribedBy'] ?? json['prescribed_by'] ?? '').toString(),
      date: (json['date'] ?? json['prescription_date'] ?? '').toString(),
      medications: medsRaw
          .whereType<Map<String, dynamic>>()
          .map((m) => PrescriptionMedicationItem.fromJson(m))
          .toList(),
    );
  }
}
