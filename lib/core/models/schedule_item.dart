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

  static ScheduleType _parseType(String? type) {
    if (type == null) return ScheduleType.appointment;
    final normalized = type.toLowerCase();
    if (normalized.contains('activit') || normalized.contains('event')) {
      return ScheduleType.clinicActivity;
    }
    if (normalized.contains('clinic') || normalized.contains('staff') || normalized.contains('duty')) {
      return ScheduleType.clinicSchedule;
    }
    return ScheduleType.appointment;
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? json['reference'] ?? 'Schedule Item').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? json['startDate']?.toString() ?? '') ?? DateTime.now(),
      time: json['time']?.toString() ?? json['startTime']?.toString(),
      type: _parseType(json['type']?.toString()),
      description: json['description']?.toString() ?? json['reason']?.toString(),
    );
  }
}
