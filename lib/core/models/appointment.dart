enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }

class Appointment {
  final String id;
  final String title;
  final String reason;
  final DateTime date;
  final String time;
  final AppointmentStatus status;
  final String doctorName;

  const Appointment({
    required this.id,
    required this.title,
    required this.reason,
    required this.date,
    required this.time,
    required this.status,
    required this.doctorName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reason': reason,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.name,
      'doctorName': doctorName,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      title: json['title'] as String,
      reason: json['reason'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      doctorName: json['doctorName'] as String,
    );
  }
}
