import 'clinic_schedule.dart';
import 'staff_schedule.dart';
import 'clinic_activity_detail.dart';

class ClinicInformation {
  final String name;
  final String description;
  final String address;
  final String contactNumber;
  final String email;
  final List<String> services;
  final ClinicSchedule? schedule;
  final List<StaffSchedule> staffSchedules;
  final List<ClinicActivityDetail> activities;
  final String? operatingHours;

  ClinicSchedule? get clinicSchedule => schedule;

  const ClinicInformation({
    required this.name,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.email,
    required this.services,
    this.schedule,
    this.staffSchedules = const [],
    this.activities = const [],
    this.operatingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'contactNumber': contactNumber,
      'email': email,
      'services': services,
      'schedule': schedule?.toJson(),
      'operatingHours': operatingHours,
    };
  }

  factory ClinicInformation.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'] as List?;
    final defaultServices = [
      'General Medical Consultation',
      'First Aid & Emergency Care',
      'Physical Examination & Health Clearance',
      'Prescription & Medication Guidance',
      'Vital Signs & Blood Pressure Monitoring',
      'Vaccination & Immunization Drives',
    ];

    List<String> parsedServices;
    if (servicesRaw != null && servicesRaw.isNotEmpty) {
      parsedServices = servicesRaw.map((s) => s.toString()).toList();
    } else {
      parsedServices = defaultServices;
    }

    ClinicSchedule? parsedSchedule;
    if (json['schedule'] is Map<String, dynamic>) {
      parsedSchedule = ClinicSchedule.fromJson(json['schedule'] as Map<String, dynamic>);
    } else {
      final hours = (json['clinicHours'] ?? json['operatingHours'] ?? '8:00 AM - 5:00 PM').toString();
      final parts = hours.split('-');
      final open = parts.isNotEmpty ? parts[0].trim() : '8:00 AM';
      final close = parts.length > 1 ? parts[1].trim() : '5:00 PM';
      parsedSchedule = ClinicSchedule(weeklySchedule: [
        DaySchedule(day: 'Monday', openTime: open, closeTime: close),
        DaySchedule(day: 'Tuesday', openTime: open, closeTime: close),
        DaySchedule(day: 'Wednesday', openTime: open, closeTime: close),
        DaySchedule(day: 'Thursday', openTime: open, closeTime: close),
        DaySchedule(day: 'Friday', openTime: open, closeTime: close),
        const DaySchedule(day: 'Saturday', openTime: '', closeTime: '', isClosed: true),
        const DaySchedule(day: 'Sunday', openTime: '', closeTime: '', isClosed: true),
      ]);
    }

    List<StaffSchedule> parsedStaff = [];
    if (json['staffSchedules'] is List) {
      parsedStaff = (json['staffSchedules'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => StaffSchedule.fromJson(s))
          .toList();
    }

    List<ClinicActivityDetail> parsedActivities = [];
    if (json['activities'] is List) {
      parsedActivities = (json['activities'] as List)
          .whereType<Map<String, dynamic>>()
          .map((a) => ClinicActivityDetail.fromJson(a))
          .toList();
    }

    return ClinicInformation(
      name: (json['clinicName'] ?? json['name'] ?? 'TMC Medical Clinic').toString(),
      description: (json['clinicDescription'] ?? json['description'] ?? 'TMC CareLink Clinic provides medical services to the campus community.').toString(),
      address: (json['clinicAddress'] ?? json['address'] ?? 'Ground Floor, Health Sciences Building, Main Campus').toString(),
      contactNumber: (json['clinicPhone'] ?? json['contactNumber'] ?? '+63 (02) 8123-4567').toString(),
      email: (json['clinicEmail'] ?? json['email'] ?? 'clinic@tmccarelink.com').toString(),
      services: parsedServices,
      schedule: parsedSchedule,
      staffSchedules: parsedStaff,
      activities: parsedActivities,
      operatingHours: (json['clinicHours'] ?? json['operatingHours'] ?? '8:00 AM - 5:00 PM').toString(),
    );
  }
}
