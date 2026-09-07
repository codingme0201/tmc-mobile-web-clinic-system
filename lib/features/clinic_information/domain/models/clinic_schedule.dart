class DaySchedule {
  final String day;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  const DaySchedule({
    required this.day,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: json['day'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}

class ClinicSchedule {
  final List<DaySchedule> weeklySchedule;

  const ClinicSchedule({required this.weeklySchedule});

  Map<String, dynamic> toJson() {
    return {
      'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
    };
  }

  factory ClinicSchedule.fromJson(Map<String, dynamic> json) {
    return ClinicSchedule(
      weeklySchedule: (json['weeklySchedule'] as List)
          .map((d) => DaySchedule.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
