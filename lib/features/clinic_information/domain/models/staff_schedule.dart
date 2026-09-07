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
      day: json['day'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
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
    return StaffSchedule(
      id: json['id'] as String,
      name: json['name'] as String,
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.doctor,
      ),
      specialty: json['specialty'] as String,
      schedule: (json['schedule'] as List)
          .map((s) => StaffScheduleEntry.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
