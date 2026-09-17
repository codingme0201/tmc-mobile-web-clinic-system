import 'package:meta/meta.dart';

@immutable
class MedicalCertificate {
  final String id;
  final String reference;
  final String patient;
  final String patientId;
  final String? consultationId;
  final String issuedBy;
  final String requestedBy;
  final String approvedBy;
  final String? approvedAt;
  final String? rejectedAt;
  final String rejectionReason;
  final String purpose;
  final String diagnosis;
  final String recommendation;
  final String issueDate;
  final String? validUntil;
  final String status;
  final String? issuedAt;

  const MedicalCertificate({
    required this.id,
    required this.reference,
    required this.patient,
    required this.patientId,
    this.consultationId,
    required this.issuedBy,
    required this.requestedBy,
    required this.approvedBy,
    this.approvedAt,
    this.rejectedAt,
    required this.rejectionReason,
    required this.purpose,
    required this.diagnosis,
    required this.recommendation,
    required this.issueDate,
    this.validUntil,
    required this.status,
    this.issuedAt,
  });

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: json['id']?.toString() ?? '',
      reference: (json['reference'] ?? '').toString(),
      patient: (json['patient'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      consultationId: json['consultationId']?.toString(),
      issuedBy: (json['issuedBy'] ?? json['issued_by'] ?? '').toString(),
      requestedBy: (json['requestedBy'] ?? json['requested_by'] ?? '').toString(),
      approvedBy: (json['approvedBy'] ?? json['approved_by'] ?? '').toString(),
      approvedAt: json['approvedAt']?.toString(),
      rejectedAt: json['rejectedAt']?.toString(),
      rejectionReason: (json['rejectionReason'] ?? json['rejection_reason'] ?? '').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      diagnosis: (json['diagnosis'] ?? '').toString(),
      recommendation: (json['recommendation'] ?? '').toString(),
      issueDate: (json['issueDate'] ?? json['issue_date'] ?? '').toString(),
      validUntil: json['validUntil']?.toString(),
      status: (json['status'] ?? 'Pending').toString(),
      issuedAt: json['issuedAt']?.toString(),
    );
  }
}
