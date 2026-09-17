enum ConsultationStatus { scheduled, inProgress, completed, cancelled }

class Consultation {
  final String id;
  final String title;
  final String doctorName;
  final DateTime date;
  final String time;
  final ConsultationStatus status;
  final String? diagnosis;

  const Consultation({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.status,
    this.diagnosis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.name,
      'diagnosis': diagnosis,
    };
  }

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
      title: (json['reference'] ?? json['title'] ?? json['chiefComplaint'] ?? json['chief_complaint'] ?? 'Consultation').toString(),
      doctorName: (json['staff'] ?? json['doctorName'] ?? 'TMC Medical Staff').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      time: (json['time'] ?? '').toString(),
      status: _parseStatus(json['status']?.toString()),
      diagnosis: json['diagnosis']?.toString(),
    );
  }
}
