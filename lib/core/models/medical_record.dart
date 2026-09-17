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
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? json['name'] ?? 'Medical Record').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
      type: (json['type'] ?? 'Record').toString(),
      summary: json['summary']?.toString() ?? json['status']?.toString(),
    );
  }
}
