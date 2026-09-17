import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/account_security_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/clinic_information/presentation/screens/clinic_information_screen.dart';
import '../features/clinic_information/presentation/screens/clinic_schedule_screen.dart';
import '../features/clinic_information/presentation/screens/staff_schedule_screen.dart';
import '../features/clinic_information/presentation/screens/clinic_activities_screen.dart';
import '../features/appointments/presentation/screens/appointments_screen.dart';
import '../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../features/consultations/presentation/screens/consultations_screen.dart';
import '../features/consultations/presentation/screens/consultation_detail_screen.dart';
import '../features/medical_records/presentation/screens/medical_records_screen.dart';
import '../features/medical_certificates/presentation/screens/medical_certificates_screen.dart';
import '../features/prescriptions/presentation/screens/prescriptions_screen.dart';
import '../core/widgets/main_shell.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String mainShell = '/main';
  static const String changePassword = '/change-password';
  static const String accountSecurity = '/account-security';
  static const String profile = '/profile';
  static const String clinicInformation = '/clinic-information';
  static const String clinicSchedule = '/clinic-schedule';
  static const String staffSchedule = '/staff-schedule';
  static const String clinicActivities = '/clinic-activities';
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointment-detail';
  static const String consultations = '/consultations';
  static const String consultationDetail = '/consultation-detail';
  static const String medicalRecords = '/medical-records';
  static const String medicalCertificates = '/medical-certificates';
  static const String prescriptions = '/prescriptions';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case mainShell:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: MainShell()));
      case changePassword:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ChangePasswordScreen()));
      case accountSecurity:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: AccountSecurityScreen()));
      case profile:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ProfileScreen()));
      case clinicInformation:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ClinicInformationScreen()));
      case clinicSchedule:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ClinicScheduleScreen()));
      case staffSchedule:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: StaffScheduleScreen()));
      case clinicActivities:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ClinicActivitiesScreen()));
      case appointments:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: AppointmentsScreen()));
      case appointmentDetail:
        final appointmentId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: AppointmentDetailScreen(appointmentId: appointmentId),
          ),
        );
      case consultations:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ConsultationsScreen()));
      case consultationDetail:
        final consultationId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: ConsultationDetailScreen(consultationId: consultationId),
          ),
        );
      case medicalRecords:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: MedicalRecordsScreen()));
      case medicalCertificates:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: MedicalCertificatesScreen()));
      case prescriptions:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: PrescriptionsScreen()));
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pushReplacementNamed(context, AppRouter.login);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return child;
      },
    );
  }
}
