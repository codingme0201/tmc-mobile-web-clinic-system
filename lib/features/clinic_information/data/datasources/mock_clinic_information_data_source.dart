import '../../domain/models/clinic_information.dart';
import '../../domain/models/clinic_schedule.dart';
import '../../domain/models/staff_schedule.dart';
import '../../domain/models/clinic_activity_detail.dart';

class ClinicInformationData {
  final ClinicInformation clinicInfo;
  final ClinicSchedule clinicSchedule;
  final List<StaffSchedule> staffSchedules;
  final List<ClinicActivityDetail> activities;

  const ClinicInformationData({
    required this.clinicInfo,
    required this.clinicSchedule,
    required this.staffSchedules,
    required this.activities,
  });
}

class MockClinicInformationDataSource {
  static final MockClinicInformationDataSource instance =
      MockClinicInformationDataSource._();
  MockClinicInformationDataSource._();

  ClinicInformationData getData() {
    const clinicInfo = ClinicInformation(
      name: 'TMC Student Health Clinic',
      description:
          'The TMC Student Health Clinic provides comprehensive healthcare services to enrolled students, '
          'faculty, and staff. Our team of qualified medical professionals is dedicated to promoting '
          'the health and well-being of the campus community.',
      address: 'TMC Building, 2nd Floor, Room 205, Rizal Avenue, Quezon City',
      contactNumber: '(02) 8123-4567',
      email: 'clinic@tmc.edu.ph',
      services: [
        'General Medical Consultation',
        'Dental Services',
        'Vision/Eye Examination',
        'Vaccination & Immunization',
        'Laboratory Services',
        'Mental Health Support',
        'Health Screening',
        'First Aid & Emergency Care',
      ],
    );

    const clinicSchedule = ClinicSchedule(weeklySchedule: [
      DaySchedule(day: 'Monday', openTime: '8:00 AM', closeTime: '5:00 PM'),
      DaySchedule(day: 'Tuesday', openTime: '8:00 AM', closeTime: '5:00 PM'),
      DaySchedule(day: 'Wednesday', openTime: '8:00 AM', closeTime: '5:00 PM'),
      DaySchedule(day: 'Thursday', openTime: '8:00 AM', closeTime: '5:00 PM'),
      DaySchedule(day: 'Friday', openTime: '8:00 AM', closeTime: '5:00 PM'),
      DaySchedule(day: 'Saturday', openTime: '', closeTime: '', isClosed: true),
      DaySchedule(day: 'Sunday', openTime: '', closeTime: '', isClosed: true),
    ]);

    final staffSchedules = [
      const StaffSchedule(
        id: 'staff-1',
        name: 'Dr. Maria Santos',
        role: StaffRole.doctor,
        specialty: 'General Medicine',
        schedule: [
          StaffScheduleEntry(day: 'Monday', startTime: '8:00 AM', endTime: '12:00 PM'),
          StaffScheduleEntry(day: 'Wednesday', startTime: '1:00 PM', endTime: '5:00 PM'),
          StaffScheduleEntry(day: 'Friday', startTime: '8:00 AM', endTime: '12:00 PM'),
        ],
      ),
      const StaffSchedule(
        id: 'staff-2',
        name: 'Dr. Angelo Cruz',
        role: StaffRole.doctor,
        specialty: 'Dentistry',
        schedule: [
          StaffScheduleEntry(day: 'Tuesday', startTime: '8:00 AM', endTime: '12:00 PM'),
          StaffScheduleEntry(day: 'Thursday', startTime: '1:00 PM', endTime: '5:00 PM'),
        ],
      ),
      const StaffSchedule(
        id: 'staff-3',
        name: 'Dr. Elena Reyes',
        role: StaffRole.doctor,
        specialty: 'General Medicine',
        schedule: [
          StaffScheduleEntry(day: 'Monday', startTime: '1:00 PM', endTime: '5:00 PM'),
          StaffScheduleEntry(day: 'Wednesday', startTime: '8:00 AM', endTime: '12:00 PM'),
          StaffScheduleEntry(day: 'Friday', startTime: '1:00 PM', endTime: '5:00 PM'),
        ],
      ),
      const StaffSchedule(
        id: 'staff-4',
        name: 'Nurse Joy Lim',
        role: StaffRole.nurse,
        specialty: 'Nursing Services',
        schedule: [
          StaffScheduleEntry(day: 'Monday', startTime: '8:00 AM', endTime: '4:00 PM'),
          StaffScheduleEntry(day: 'Tuesday', startTime: '8:00 AM', endTime: '4:00 PM'),
          StaffScheduleEntry(day: 'Wednesday', startTime: '8:00 AM', endTime: '4:00 PM'),
          StaffScheduleEntry(day: 'Thursday', startTime: '8:00 AM', endTime: '4:00 PM'),
          StaffScheduleEntry(day: 'Friday', startTime: '8:00 AM', endTime: '4:00 PM'),
        ],
      ),
      const StaffSchedule(
        id: 'staff-5',
        name: 'Nurse Mark Torres',
        role: StaffRole.nurse,
        specialty: 'Nursing Services',
        schedule: [
          StaffScheduleEntry(day: 'Monday', startTime: '8:00 AM', endTime: '4:00 PM'),
          StaffScheduleEntry(day: 'Wednesday', startTime: '8:00 AM', endTime: '4:00 PM'),
          StaffScheduleEntry(day: 'Friday', startTime: '8:00 AM', endTime: '4:00 PM'),
        ],
      ),
    ];

    final now = DateTime.now();
    final activities = [
      ClinicActivityDetail(
        id: 'act-1',
        title: 'Free Flu Vaccination Drive',
        description:
            'Free influenza vaccines available for all enrolled students. '
            'Bring your student ID. Walk-ins welcome on a first-come, first-served basis.',
        date: now.add(const Duration(days: 2)),
        time: '9:00 AM – 3:00 PM',
        location: 'Clinic Lobby',
        status: ActivityStatus.upcoming,
      ),
      ClinicActivityDetail(
        id: 'act-2',
        title: 'Mental Health Awareness Week',
        description:
            'Join us for a series of workshops and seminars focused on mental health '
            'awareness and stress management for students.',
        date: now.add(const Duration(days: 8)),
        time: '10:00 AM – 12:00 PM',
        location: 'TMC Auditorium',
        status: ActivityStatus.upcoming,
      ),
      ClinicActivityDetail(
        id: 'act-3',
        title: 'Free Health Screening',
        description:
            'Comprehensive health screening including blood pressure, BMI, '
            'and basic laboratory tests. Open to all students and staff.',
        date: now.add(const Duration(days: 14)),
        time: '8:00 AM – 12:00 PM',
        location: 'Clinic Examination Room',
        status: ActivityStatus.upcoming,
      ),
      ClinicActivityDetail(
        id: 'act-4',
        title: 'Clinic Equipment Maintenance',
        description:
            'The clinic will undergo scheduled equipment maintenance. '
            'Some services may have limited availability during this period.',
        date: now.subtract(const Duration(days: 3)),
        time: '8:00 AM – 5:00 PM',
        location: 'TMC Student Health Clinic',
        status: ActivityStatus.completed,
      ),
    ];

    return ClinicInformationData(
      clinicInfo: clinicInfo,
      clinicSchedule: clinicSchedule,
      staffSchedules: staffSchedules,
      activities: activities,
    );
  }

  ClinicInformation getClinicInformation() {
    final data = getData();
    return ClinicInformation(
      name: data.clinicInfo.name,
      description: data.clinicInfo.description,
      address: data.clinicInfo.address,
      contactNumber: data.clinicInfo.contactNumber,
      email: data.clinicInfo.email,
      services: data.clinicInfo.services,
      schedule: data.clinicSchedule,
      staffSchedules: data.staffSchedules,
      activities: data.activities,
      operatingHours: '8:00 AM - 5:00 PM',
    );
  }
}
