enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }

class Appointment {
  final String id;
  final String title;
  final String reason;
  final DateTime date;
  final String time;
  final AppointmentStatus status;
  final String doctorName;
  final String type;
  final String clinic;
  final String? notes;
  final DateTime? requestedOn;
  final DateTime? updatedAt;
  final String? cancelReason;

  const Appointment({
    required this.id,
    required this.title,
    required this.reason,
    required this.date,
    required this.time,
    required this.status,
    required this.doctorName,
    this.type = 'Check-up',
    this.clinic = 'TMC Student Health Clinic',
    this.notes,
    this.requestedOn,
    this.updatedAt,
    this.cancelReason,
  });

  Appointment copyWith({
    String? id,
    String? title,
    String? reason,
    DateTime? date,
    String? time,
    AppointmentStatus? status,
    String? doctorName,
    String? type,
    String? clinic,
    String? notes,
    DateTime? requestedOn,
    DateTime? updatedAt,
    String? cancelReason,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      doctorName: doctorName ?? this.doctorName,
      type: type ?? this.type,
      clinic: clinic ?? this.clinic,
      notes: notes ?? this.notes,
      requestedOn: requestedOn ?? this.requestedOn,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reason': reason,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.name,
      'doctorName': doctorName,
      'type': type,
      'clinic': clinic,
      'notes': notes,
      'requestedOn': requestedOn?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancelReason': cancelReason,
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
      type: json['type'] as String? ?? 'Check-up',
      clinic: json['clinic'] as String? ?? 'TMC Student Health Clinic',
      notes: json['notes'] as String?,
      requestedOn: json['requestedOn'] != null
          ? DateTime.parse(json['requestedOn'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      cancelReason: json['cancelReason'] as String?,
    );
  }
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No-Show';
    }
  }

  String get description {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Your appointment request is awaiting confirmation.';
      case AppointmentStatus.confirmed:
        return 'Your appointment has been confirmed.';
      case AppointmentStatus.completed:
        return 'Your appointment has been completed.';
      case AppointmentStatus.cancelled:
        return 'This appointment has been cancelled.';
      case AppointmentStatus.noShow:
        return 'You did not attend this appointment.';
    }
  }
}
