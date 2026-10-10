import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'api_client.dart';
import '../../features/appointments/presentation/controllers/appointment_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/clinic_information/presentation/controllers/clinic_information_controller.dart';
import '../../features/consultations/presentation/controllers/consultation_controller.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/medical_certificates/presentation/controllers/medical_certificate_controller.dart';
import '../../features/medical_records/presentation/controllers/medical_record_controller.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';

/// Real-time sync with the web clinic system.
///
/// Every [interval] the app asks the server for its per-module change
/// versions (`GET /api/sync`, one tiny request). Only the modules that
/// changed since the previous poll are re-fetched, silently, so whatever the
/// clinic staff do on the web (approve an appointment, add a prescription,
/// send a notification, edit a record...) appears within a few seconds
/// without a manual refresh or restart. Screens that hold their own data
/// (detail pages, slot pickers) listen to [changes].
///
/// A revoked session (account deactivated or deleted on the web) signs the
/// student out.
class LiveSync with WidgetsBindingObserver {
  LiveSync(this._context, {this.interval = const Duration(seconds: 3)});

  /// Emits the set of modules that just changed on the server.
  static final StreamController<Set<String>> _changes = StreamController<Set<String>>.broadcast();
  static Stream<Set<String>> get changes => _changes.stream;

  final BuildContext _context;
  final Duration interval;
  final ApiClient _api = ApiClient();
  Timer? _timer;
  bool _polling = false;
  Map<String, dynamic>? _versions;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _schedule();
    poll();
  }

  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => poll());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _schedule();
      poll();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  Future<void> poll() async {
    if (_polling || !_context.mounted) return;
    final auth = _context.read<AuthController>();
    if (!auth.isAuthenticated) return;

    _polling = true;
    try {
      final response = await _api.get('/sync');
      if (response.statusCode == 401) {
        if (_context.mounted && auth.isAuthenticated) await auth.logout();
        return;
      }
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      final versions = Map<String, dynamic>.from((decoded is Map ? decoded['data'] : null) as Map? ?? {});
      final previous = _versions;
      _versions = versions;
      if (previous == null) return;

      final changed = versions.keys.where((k) => versions[k] != previous[k]).toSet();
      if (changed.isEmpty) return;

      _changes.add(changed);
      await _refresh(changed);
    } catch (_) {
      // Offline or server restarting: keep what is on screen and retry next tick.
    } finally {
      _polling = false;
    }
  }

  Future<void> _refresh(Set<String> changed) async {
    if (!_context.mounted) return;
    bool any(List<String> modules) => modules.any(changed.contains);

    final auth = _context.read<AuthController>();
    final appointments = _context.read<AppointmentController>();
    final clinicInfo = _context.read<ClinicInformationController>();
    final consultations = _context.read<ConsultationController>();
    final certificates = _context.read<MedicalCertificateController>();
    final records = _context.read<MedicalRecordController>();
    final prescriptions = _context.read<PrescriptionController>();
    final profile = _context.read<ProfileController>();

    await Future.wait([
      if (any(['notifications']))
        _context.read<NotificationController>().loadNotifications(silent: true),
      if (any(['appointments', 'consultations', 'medical_records', 'patients', 'prescriptions']))
        _context.read<DashboardController>().loadDashboard(silent: true),
      if (any(['appointments', 'users']) && appointments.status != AppointmentListStatus.initial)
        appointments.loadAppointments(silent: true),
      if (any(['settings', 'staff_profiles', 'staff_schedules', 'users']) && clinicInfo.status != ClinicInfoStatus.initial)
        clinicInfo.loadClinicInformation(silent: true),
      if (any(['consultations']) && consultations.status != ConsultationListStatus.initial)
        consultations.loadConsultations(silent: true),
      if (any(['medical_certificates']) && certificates.status != MedicalCertificateStatus.initial)
        certificates.loadCertificates(silent: true),
      if (any(['medical_records', 'patients', 'prescriptions']) && records.status != MedicalRecordStatus.initial)
        records.loadMedicalRecord(silent: true),
      if (any(['prescriptions']) && prescriptions.status != PrescriptionListStatus.initial)
        prescriptions.loadPrescriptions(silent: true),
      if (any(['patients', 'users']) && profile.status == ProfileStatus.loaded && auth.session != null)
        profile.loadProfile(auth.session!.user.id, silent: true),
    ]);
  }
}
