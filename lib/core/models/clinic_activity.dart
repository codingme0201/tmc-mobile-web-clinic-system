class ClinicActivity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type;

  const ClinicActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory ClinicActivity.fromJson(Map<String, dynamic> json) {
    return ClinicActivity(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? json['startDate']?.toString() ?? json['start_date']?.toString() ?? '') ?? DateTime.now(),
      type: (json['type'] ?? 'Activity').toString(),
    );
  }
}
