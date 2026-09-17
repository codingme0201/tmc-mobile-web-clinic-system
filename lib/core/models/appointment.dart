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

  static AppointmentStatus _parseStatus(String? status) {
    if (status == null) return AppointmentStatus.pending;
    final normalized = status.toLowerCase().replaceAll('-', '').replaceAll(' ', '').replaceAll('_', '');
    if (normalized.contains('confirm') || normalized.contains('approved')) {
      return AppointmentStatus.confirmed;
    }
    if (normalized.contains('complete')) {
      return AppointmentStatus.completed;
    }
    if (normalized.contains('cancel')) {
      return AppointmentStatus.cancelled;
    }
    if (normalized.contains('noshow')) {
      return AppointmentStatus.noShow;
    }
    return AppointmentStatus.pending;
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      title: (json['reference'] ?? json['title'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      time: (json['time'] ?? '').toString(),
      status: _parseStatus(json['status']?.toString()),
      doctorName: (json['staff'] ?? json['doctorName'] ?? 'TMC Medical Staff').toString(),
      type: (json['type'] ?? 'Check-up').toString(),
      clinic: (json['clinic'] ?? 'TMC Student Health Clinic').toString(),
      notes: json['notes']?.toString(),
      requestedOn: json['requestedOn'] != null
          ? DateTime.tryParse(json['requestedOn'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      cancelReason: json['cancelReason']?.toString(),
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
