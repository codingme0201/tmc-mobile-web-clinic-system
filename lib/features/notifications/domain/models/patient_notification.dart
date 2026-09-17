import 'package:meta/meta.dart';

@immutable
class PatientNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String category;
  final String source;
  final bool isRead;
  final String createdAt;

  const PatientNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.source,
    required this.isRead,
    required this.createdAt,
  });

  factory PatientNotification.fromJson(Map<String, dynamic> json) {
    return PatientNotification(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'info').toString(),
      category: (json['category'] ?? 'general').toString(),
      source: (json['source'] ?? 'System').toString(),
      isRead: json['isRead'] == true || json['is_read'] == 1 || json['is_read'] == true,
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
    );
  }

  PatientNotification copyWith({bool? isRead}) {
    return PatientNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      category: category,
      source: source,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
