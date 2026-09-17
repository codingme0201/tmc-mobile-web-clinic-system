enum StaffRole { doctor, nurse }

class StaffScheduleEntry {
  final String day;
  final String startTime;
  final String endTime;

  const StaffScheduleEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory StaffScheduleEntry.fromJson(Map<String, dynamic> json) {
    return StaffScheduleEntry(
      day: (json['day'] ?? json['date'] ?? '').toString(),
      startTime: (json['startTime'] ?? json['start_time'] ?? '').toString(),
      endTime: (json['endTime'] ?? json['end_time'] ?? '').toString(),
    );
  }
}

class StaffSchedule {
  final String id;
  final String name;
  final StaffRole role;
  final String specialty;
  final List<StaffScheduleEntry> schedule;

  const StaffSchedule({
    required this.id,
    required this.name,
    required this.role,
    required this.specialty,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'specialty': specialty,
      'schedule': schedule.map((s) => s.toJson()).toList(),
    };
  }

  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['role'] ?? json['user']?['role'] ?? '').toString().toLowerCase();
    final isNurse = rawRole.contains('nurse');

    List<StaffScheduleEntry> entries = [];
    if (json['schedule'] is List) {
      entries = (json['schedule'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => StaffScheduleEntry.fromJson(s))
          .toList();
    } else if (json['startTime'] != null || json['start_time'] != null) {
      entries = [StaffScheduleEntry.fromJson(json)];
    }

    return StaffSchedule(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['user']?['name'] ?? 'Medical Staff').toString(),
      role: isNurse ? StaffRole.nurse : StaffRole.doctor,
      specialty: (json['specialty'] ?? (isNurse ? 'Nursing Services' : 'General Medicine')).toString(),
      schedule: entries,
    );
  }
}
