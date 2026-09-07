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
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
    );
  }
}
