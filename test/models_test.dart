import 'package:flutter_test/flutter_test.dart';
import 'package:carelink_mobile/core/models/appointment.dart';
import 'package:carelink_mobile/features/consultations/domain/models/consultation.dart';
import 'package:carelink_mobile/features/medical_records/domain/models/medical_record.dart';
import 'package:carelink_mobile/features/medical_certificates/domain/models/medical_certificate.dart';
import 'package:carelink_mobile/features/prescriptions/domain/models/prescription.dart';
import 'package:carelink_mobile/features/notifications/domain/models/patient_notification.dart';
import 'package:carelink_mobile/features/clinic_information/domain/models/clinic_information.dart';
import 'package:carelink_mobile/features/profile/domain/models/profile.dart';

void main() {
  group('Backend JSON Model Deserialization Tests', () {
    test('Appointment.fromJson parses backend Laravel resource shape correctly', () {
      final json = {
        'id': 1,
        'reference': 'APT-2026-0001',
        'patient': 'Angela Reyes',
        'patientId': '2023-0104',
        'date': '2026-09-20',
        'time': '09:00 AM',
        'type': 'General Consultation',
        'status': 'Confirmed',
        'reason': 'Annual health clearance',
        'staff': 'Dr. Maria Santos',
      };

      final apt = Appointment.fromJson(json);
      expect(apt.id, '1');
      expect(apt.doctorName, 'Dr. Maria Santos');
      expect(apt.status, AppointmentStatus.confirmed);
    });

    test('Consultation.fromJson parses backend Laravel resource shape correctly', () {
      final json = {
        'id': 10,
        'reference': 'CNS-2026-0010',
        'patient': 'Angela Reyes',
        'patientId': '2023-0104',
        'date': '2026-09-15',
        'status': 'Completed',
        'chiefComplaint': 'Persistent cough and sore throat',
        'diagnosis': 'Acute Pharyngitis',
        'notes': 'Prescribed oral antibiotics and rest for 3 days.',
        'staff': 'Dr. Maria Santos',
        'temperature': '37.8',
        'bloodPressure': '118/76',
        'pulseRate': '82',
        'respiratoryRate': '18',
        'weight': '54',
        'height': '162',
      };

      final cns = Consultation.fromJson(json);
      expect(cns.id, '10');
      expect(cns.reference, 'CNS-2026-0010');
      expect(cns.chiefComplaint, 'Persistent cough and sore throat');
      expect(cns.diagnosis, 'Acute Pharyngitis');
      expect(cns.staff, 'Dr. Maria Santos');
      expect(cns.vitals['bloodPressure'], '118/76');
      expect(cns.vitals['temperature'], '37.8');
    });

    test('MedicalRecord.fromJson parses backend Laravel resource shape correctly', () {
      final json = {
        'id': 1,
        'patientId': '2023-0104',
        'name': 'Angela Reyes',
        'age': 20,
        'sex': 'Female',
        'type': 'Student',
        'courseDept': 'BS Nursing',
        'contact': '0917-123-4567',
        'emergencyContact': 'Maria Reyes (0918-765-4321)',
        'status': 'Active',
        'lastUpdated': '2026-09-17',
        'medicalHistory': [
          {
            'id': '1',
            'date': '2025-06-10',
            'condition': 'Mild Bronchitis',
            'notes': 'Resolved after course of antibiotics',
          }
        ],
        'conditions': [
          {
            'id': '2',
            'name': 'Allergic Rhinitis',
            'status': 'Active',
            'diagnosedDate': '2024-03-12',
            'notes': 'Seasonal dust triggers',
          }
        ],
        'allergies': [
          {
            'id': '3',
            'allergen': 'Penicillin',
            'reaction': 'Skin rash and hives',
            'severity': 'Severe',
            'dateRecorded': '2023-09-01',
            'notes': 'Patient carries alert card',
          }
        ],
        'medications': [
          {
            'id': '4',
            'name': 'Cetirizine 10mg',
            'dosage': '10mg',
            'frequency': 'Once daily at bedtime',
            'route': 'Oral',
            'status': 'Active',
            'instructions': 'Take when experiencing symptoms',
          }
        ],
      };

      final record = MedicalRecord.fromJson(json);
      expect(record.id, '1');
      expect(record.name, 'Angela Reyes');
      expect(record.age, 20);
      expect(record.medicalHistory.length, 1);
      expect(record.medicalHistory.first.condition, 'Mild Bronchitis');
      expect(record.conditions.first.name, 'Allergic Rhinitis');
      expect(record.allergies.first.allergen, 'Penicillin');
      expect(record.medications.first.name, 'Cetirizine 10mg');
    });

    test('MedicalCertificate.fromJson parses backend Laravel resource shape correctly', () {
      final json = {
        'id': 5,
        'reference': 'MC-2026-0005',
        'patient': 'Angela Reyes',
        'patientId': '2023-0104',
        'issuedBy': 'Dr. Maria Santos',
        'requestedBy': 'Angela Reyes',
        'approvedBy': 'Dr. Maria Santos',
        'purpose': 'Excused Absence due to illness',
        'diagnosis': 'Acute Pharyngitis',
        'recommendation': 'Bed rest for 2 days',
        'issueDate': '2026-09-16',
        'validUntil': '2026-09-18',
        'status': 'Issued',
      };

      final cert = MedicalCertificate.fromJson(json);
      expect(cert.id, '5');
      expect(cert.reference, 'MC-2026-0005');
      expect(cert.purpose, 'Excused Absence due to illness');
      expect(cert.status, 'Issued');
      expect(cert.issuedBy, 'Dr. Maria Santos');
    });

    test('Prescription.fromJson parses backend Laravel resource shape correctly', () {
      final json = {
        'id': 3,
        'reference': 'RX-2026-0003',
        'patient': 'Angela Reyes',
        'patientId': '2023-0104',
        'prescribedBy': 'Dr. Maria Santos',
        'date': '2026-09-15',
        'medications': [
          {
            'id': '1',
            'medicineName': 'Amoxicillin 500mg',
            'dosage': '500mg capsule',
            'frequency': 'Every 8 hours',
            'duration': '7 days',
            'instructions': 'Take after meals. Complete full 7-day course.',
          },
          {
            'id': '2',
            'medicineName': 'Paracetamol 500mg',
            'dosage': '500mg tablet',
            'frequency': 'Every 4-6 hours as needed',
            'duration': '3 days',
            'instructions': 'Take for fever or pain above 38C.',
          }
        ],
      };

      final rx = Prescription.fromJson(json);
      expect(rx.id, '3');
      expect(rx.reference, 'RX-2026-0003');
      expect(rx.medications.length, 2);
      expect(rx.medications.first.medicineName, 'Amoxicillin 500mg');
      expect(rx.medications.first.frequency, 'Every 8 hours');
    });

    test('PatientNotification.fromJson parses backend Laravel resource shape correctly', () {
      final json = {
        'id': 12,
        'userId': 4,
        'title': 'Prescription Issued',
        'message': 'A new prescription RX-2026-0003 has been issued for your consultation.',
        'type': 'prescription',
        'category': 'prescription',
        'source': 'Consultation',
        'isRead': false,
        'createdAt': '2026-09-17T08:30:00.000000Z',
      };

      final notif = PatientNotification.fromJson(json);
      expect(notif.id, '12');
      expect(notif.title, 'Prescription Issued');
      expect(notif.isRead, false);
      expect(notif.category, 'prescription');

      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, true);
    });

    test('ClinicInformation.fromJson parses backend settings and schedule correctly', () {
      final json = {
        'clinicName': 'TMC CareLink Medical Clinic',
        'clinicDescription': 'Quality campus healthcare services',
        'clinicAddress': 'Health Sciences Building, Room 102',
        'clinicPhone': '+63 (02) 8123-4567',
        'clinicEmail': 'clinic@tmccarelink.com',
        'clinicHours': '8:00 AM - 5:00 PM',
        'services': ['General Consultation', 'First Aid'],
        'activities': [
          {
            'id': 1,
            'title': 'Blood Donation Drive',
            'description': 'Annual blood drive with Red Cross',
            'date': '2026-10-05',
            'status': 'upcoming',
          }
        ],
        'staffSchedules': [
          {
            'id': 1,
            'name': 'Dr. Maria Santos',
            'role': 'doctor',
            'specialty': 'General Medicine',
            'schedule': [
              {'day': 'Monday', 'startTime': '8:00 AM', 'endTime': '12:00 PM'}
            ]
          }
        ]
      };

      final info = ClinicInformation.fromJson(json);
      expect(info.name, 'TMC CareLink Medical Clinic');
      expect(info.address, 'Health Sciences Building, Room 102');
      expect(info.activities.length, 1);
      expect(info.activities.first.title, 'Blood Donation Drive');
      expect(info.staffSchedules.length, 1);
      expect(info.staffSchedules.first.name, 'Dr. Maria Santos');
    });

    test('StudentInfo and Profile handle Block, Philippine Mobile, and Telephone correctly', () {
      final studentJson = {
        'studentId': '24-021128',
        'program': 'BS Information Technology',
        'yearLevel': '3rd Year',
        'block': 'Block 1',
        'enrollmentStatus': 'Enrolled',
      };

      final student = StudentInfo.fromJson(studentJson);
      expect(student.studentId, '24-021128');
      expect(student.block, 'Block 1');
      expect(student.section, 'Block 1'); // Backwards compatibility check
      expect(student.toJson()['block'], 'Block 1');
      expect(student.toJson()['section'], 'Block 1');

      final profileJson = {
        'id': '101',
        'name': 'Angela Reyes',
        'email': 'angela.reyes@tmc.edu.ph',
        'phone': '+63 917 123 4567',
        'telephone': '+63 (02) 8123-4567',
        'address': 'Trinidad, Bohol',
        'dateOfBirth': '2003-05-15T00:00:00.000',
        'accountStatus': 'active',
        'studentInfo': studentJson,
      };

      final profile = Profile.fromJson(profileJson);
      expect(profile.phone, '+63 917 123 4567');
      expect(profile.telephone, '+63 (02) 8123-4567');
      expect(profile.studentInfo?.studentId, '24-021128');
      expect(profile.studentInfo?.block, 'Block 1');
    });
  });
}
