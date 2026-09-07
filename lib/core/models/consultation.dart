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

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      title: json['title'] as String,
      doctorName: json['doctorName'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: ConsultationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsultationStatus.scheduled,
      ),
      diagnosis: json['diagnosis'] as String?,
    );
  }
}
