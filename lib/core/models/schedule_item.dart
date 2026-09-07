enum ScheduleType { appointment, clinicActivity, clinicSchedule }

class ScheduleItem {
  final String id;
  final String title;
  final DateTime date;
  final String? time;
  final ScheduleType type;
  final String? description;

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'type': type.name,
      'description': description,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScheduleType.appointment,
      ),
      description: json['description'] as String?,
    );
  }
}
