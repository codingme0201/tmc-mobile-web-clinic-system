import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carelink_mobile/core/utils/api_client.dart';
import 'package:carelink_mobile/features/auth/data/datasources/auth_api_data_source.dart';
import 'package:carelink_mobile/features/appointments/data/datasources/appointment_api_data_source.dart';
import 'package:carelink_mobile/features/consultations/data/datasources/consultation_api_data_source.dart';
import 'package:carelink_mobile/features/consultations/data/repositories/consultation_api_repository.dart';
import 'package:carelink_mobile/features/medical_records/data/datasources/medical_record_api_data_source.dart';
import 'package:carelink_mobile/features/medical_certificates/data/datasources/medical_certificate_api_data_source.dart';
import 'package:carelink_mobile/features/prescriptions/data/datasources/prescription_api_data_source.dart';
import 'package:carelink_mobile/features/notifications/data/datasources/notification_api_data_source.dart';
import 'package:carelink_mobile/features/clinic_information/data/datasources/clinic_info_api_data_source.dart';
import 'package:carelink_mobile/features/profile/data/datasources/profile_api_data_source.dart';

void main() {
  group('End-to-End Backend Integration Tests', () {
    const baseUrl = 'http://127.0.0.1:8000/api';
    late String token;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. Health check endpoint responds OK', () async {
      final res = await http.get(Uri.parse('$baseUrl/health'));
      expect(res.statusCode, 200);
      final body = jsonDecode(res.body);
      expect(body['status'], 'ok');
    });

    test('2. Patient login with demo credentials', () async {
      final authDs = AuthApiDataSource();
      final res = await authDs.login(
        'demo@tmccarelink.com',
        'Demo1234',
      );

      token = res.session.token;
      expect(token, isNotEmpty);
      expect(res.session.user.email, 'demo@tmccarelink.com');
      expect(res.session.user.name, 'Angela Reyes');

      // Save token in mock SharedPreferences for subsequent ApiClient calls
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('carelink_session', jsonEncode(res.session.toJson()));
    });

    test('3. ProfileApiDataSource fetches patient profile', () async {
      final profileDs = ProfileApiDataSource();
      final profile = await profileDs.getProfile();

      expect(profile.name, 'Angela Reyes');
      expect(profile.email, 'demo@tmccarelink.com');
      expect(profile.studentInfo?.studentId, '2023-0104');
    });

    test('4. AppointmentApiDataSource fetches patient appointments', () async {
      final aptDs = AppointmentApiDataSource();
      final appointments = await aptDs.getMyAppointments();

      expect(appointments, isNotEmpty);
      for (final apt in appointments) {
        expect(apt.id, isNotEmpty);
        expect(apt.doctorName, isNotEmpty);
      }
    });

    test('5. ConsultationApiRepository fetches patient consultations', () async {
      final cnsRepo = ConsultationApiRepository();
      final consultations = await cnsRepo.getMyConsultations();

      expect(consultations, isNotEmpty);
      for (final cns in consultations) {
        expect(cns.id, isNotEmpty);
        expect(cns.reference, isNotEmpty);
      }
    });

    test('6. MedicalRecordApiDataSource fetches patient medical records', () async {
      final mrDs = MedicalRecordApiDataSource();
      final record = await mrDs.getMyMedicalRecord();

      expect(record, isNotNull);
      expect(record!['name'], 'Angela Reyes');
      expect(record['patientId'], '2023-0104');
    });

    test('7. MedicalCertificateApiDataSource fetches patient certificates', () async {
      final certDs = MedicalCertificateApiDataSource();
      final certs = await certDs.getMyCertificates();

      expect(certs, isNotEmpty);
      for (final cert in certs) {
        expect(cert.id, isNotEmpty);
        expect(cert.reference, isNotEmpty);
        expect(cert.purpose, isNotEmpty);
      }
    });

    test('8. PrescriptionApiDataSource fetches patient prescriptions', () async {
      final rxDs = PrescriptionApiDataSource();
      final prescriptions = await rxDs.getMyPrescriptions();

      expect(prescriptions, isNotEmpty);
      for (final rx in prescriptions) {
        expect(rx.id, isNotEmpty);
        expect(rx.reference, isNotEmpty);
        expect(rx.medications, isNotEmpty);
      }
    });

    test('9. NotificationApiDataSource fetches patient notifications', () async {
      final notifDs = NotificationApiDataSource();
      final notifications = await notifDs.getMyNotifications();

      expect(notifications, isNotEmpty);
      for (final notif in notifications) {
        expect(notif.id, isNotEmpty);
        expect(notif.title, isNotEmpty);
      }
    });

    test('10. ClinicInfoApiDataSource fetches clinic information and activities', () async {
      final clinicDs = ClinicInfoApiDataSource();
      final info = await clinicDs.getClinicInformation();

      expect(info.name, isNotEmpty);
      expect(info.address, isNotEmpty);
      expect(info.services, isNotEmpty);
      expect(info.activities, isNotEmpty);
      expect(info.staffSchedules, isNotEmpty);
    });

    test('11. ApiClient search endpoint queries live backend data', () async {
      final apiClient = ApiClient();
      final res = await apiClient.get('/me/search?q=Consultation');

      expect(res.statusCode, 200);
      final body = jsonDecode(res.body);
      expect(body['data'], isNotNull);
    });

    test('12. ApiClient support endpoint submits concern', () async {
      final apiClient = ApiClient();
      final res = await apiClient.post('/me/support', body: {
        'category': 'General Inquiry',
        'subject': 'Integration Test Concern',
        'message': 'This is an automated test inquiry from the mobile test suite.',
      });

      expect(res.statusCode, 201);
    });
  });
}
