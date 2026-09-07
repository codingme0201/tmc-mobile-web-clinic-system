enum ActivityStatus { upcoming, ongoing, completed }

class ClinicActivityDetail {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? time;
  final String? location;
  final ActivityStatus status;

  const ClinicActivityDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    this.location,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'status': status.name,
    };
  }

  factory ClinicActivityDetail.fromJson(Map<String, dynamic> json) {
    return ClinicActivityDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      location: json['location'] as String?,
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ActivityStatus.upcoming,
      ),
    );
  }
}
