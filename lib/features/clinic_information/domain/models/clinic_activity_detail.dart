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
    DateTime parsedDate;
    try {
      final rawDate = (json['date'] ?? json['start_date'] ?? json['startDate'] ?? '').toString();
      parsedDate = rawDate.isNotEmpty ? DateTime.parse(rawDate) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final rawStatus = (json['status'] ?? 'upcoming').toString().toLowerCase();
    ActivityStatus resolvedStatus;
    if (rawStatus.contains('ongoing') || rawStatus.contains('active')) {
      resolvedStatus = ActivityStatus.ongoing;
    } else if (rawStatus.contains('complete') || rawStatus.contains('done')) {
      resolvedStatus = ActivityStatus.completed;
    } else {
      resolvedStatus = ActivityStatus.upcoming;
    }

    return ClinicActivityDetail(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      date: parsedDate,
      time: json['time']?.toString() ?? json['start_time']?.toString(),
      location: json['location']?.toString() ?? 'Main Clinic',
      status: resolvedStatus,
    );
  }
}
