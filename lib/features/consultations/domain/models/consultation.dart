enum ConsultationStatus { scheduled, inProgress, completed, cancelled }

class Consultation {
  final String id;
  final String reference;
  final DateTime date;
  final String time;
  final String chiefComplaint;
  final String diagnosis;
  final String treatment;
  final String disposition;
  final String staff;
  final ConsultationStatus status;
  final Map<String, dynamic> vitals;
  final String clinicalFindings;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Consultation({
    required this.id,
    required this.reference,
    required this.date,
    required this.time,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.treatment,
    required this.disposition,
    required this.staff,
    required this.status,
    required this.vitals,
    required this.clinicalFindings,
    this.startedAt,
    this.completedAt,
  });

  static ConsultationStatus _parseStatus(String? status) {
    if (status == null) return ConsultationStatus.completed;
    final normalized = status.toLowerCase().replaceAll('-', '').replaceAll(' ', '').replaceAll('_', '');
    if (normalized.contains('schedule')) return ConsultationStatus.scheduled;
    if (normalized.contains('progress')) return ConsultationStatus.inProgress;
    if (normalized.contains('cancel')) return ConsultationStatus.cancelled;
    return ConsultationStatus.completed;
  }

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id']?.toString() ?? '',
      reference: (json['reference'] ?? '').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      time: (json['time'] ?? '').toString(),
      chiefComplaint: (json['chiefComplaint'] ?? json['chief_complaint'] ?? '').toString(),
      diagnosis: (json['diagnosis'] ?? '').toString(),
      treatment: (json['treatment'] ?? '').toString(),
      disposition: (json['disposition'] ?? '').toString(),
      staff: (json['staff'] ?? 'TMC Medical Staff').toString(),
      status: _parseStatus(json['status']?.toString()),
      vitals: () {
        Map<String, dynamic> v = {};
        if (json['vitals'] is Map) {
          v = Map<String, dynamic>.from(json['vitals'] as Map);
        }
        if (json['bloodPressure'] != null) v['bloodPressure'] = json['bloodPressure'];
        if (json['temperature'] != null) v['temperature'] = json['temperature'];
        if (json['pulseRate'] != null) v['pulseRate'] = json['pulseRate'];
        if (json['respiratoryRate'] != null) v['respiratoryRate'] = json['respiratoryRate'];
        if (json['weight'] != null) v['weight'] = json['weight'];
        if (json['height'] != null) v['height'] = json['height'];
        return v;
      }(),
      clinicalFindings: (json['clinicalFindings'] ?? json['clinical_findings'] ?? '').toString(),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : (json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : (json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null),
    );
  }
}
