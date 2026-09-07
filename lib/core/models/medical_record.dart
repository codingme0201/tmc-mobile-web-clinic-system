class MedicalRecord {
  final String id;
  final String title;
  final DateTime date;
  final String type;
  final String? summary;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.summary,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'summary': summary,
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      summary: json['summary'] as String?,
    );
  }
}
