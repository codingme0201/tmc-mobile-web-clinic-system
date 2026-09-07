import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/appointment_summary_card.dart';
import '../widgets/consultation_summary_card.dart';
import '../widgets/medical_record_summary_card.dart';
import '../widgets/clinic_activity_card.dart';
import '../widgets/upcoming_schedule_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthController, DashboardController>(
      builder: (context, auth, dashboard, _) {
        final user = auth.session?.user;

        return RefreshIndicator(
          onRefresh: () => dashboard.loadDashboard(),
          color: AppTheme.primary,
          child: _buildBody(context, dashboard, user?.name ?? 'User'),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DashboardController dashboard, String userName) {
    switch (dashboard.status) {
      case DashboardStatus.initial:
      case DashboardStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
      case DashboardStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
              const SizedBox(height: 16),
              Text(
                dashboard.error ?? 'Unable to load dashboard.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted, fontSize: 15),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => dashboard.loadDashboard(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        );
      case DashboardStatus.loaded:
      case DashboardStatus.refreshing:
        final data = dashboard.data;
        if (data == null) {
          return const Center(
            child: Text('No dashboard data.', style: TextStyle(color: AppTheme.muted)),
          );
        }
        return _buildDashboard(context, dashboard, userName);
    }
  }

  Widget _buildDashboard(BuildContext context, DashboardController dashboard, String userName) {
    final data = dashboard.data!;
    final appointments = data.appointments;
    final pending = appointments.where((a) => a.status.name == 'pending').length;
    final confirmed = appointments.where((a) => a.status.name == 'confirmed').length;
    final completed = appointments.where((a) => a.status.name == 'completed').length;
    final cancelled = appointments.where((a) => a.status.name == 'cancelled').length;
    final scheduledConsultations = data.consultations.where((c) => c.status.name == 'scheduled').length;
    final completedConsultations = data.consultations.where((c) => c.status.name == 'completed').length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildWelcomeHeader(userName),
            const SizedBox(height: 24),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Appointments'),
            const SizedBox(height: 12),
            AppointmentSummaryCard(
              pending: pending,
              confirmed: confirmed,
              completed: completed,
              cancelled: cancelled,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            UpcomingScheduleCard(items: data.upcomingSchedule),
            const SizedBox(height: 24),
            _buildSectionTitle('Consultations'),
            const SizedBox(height: 12),
            ConsultationSummaryCard(
              scheduled: scheduledConsultations,
              completed: completedConsultations,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Medical Records'),
            const SizedBox(height: 12),
            MedicalRecordSummaryCard(
              records: data.medicalRecords,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Clinic Activity'),
            const SizedBox(height: 12),
            ClinicActivityCard(
              activities: data.clinicActivities,
              onTap: () => Navigator.pushNamed(context, '/clinic-information'),
            ),
            const SizedBox(height: 32),
          ],
        ),
        if (dashboard.isRefreshing)
          Container(
            color: Colors.black.withAlpha(15),
            child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          ),
      ],
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withAlpha(51),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TMC CareLink Patient Portal',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.muted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(Icons.calendar_today, 'Appointments', () {}),
      _QuickAction(Icons.medical_information, 'Medical Records', () {}),
      _QuickAction(Icons.description, 'Prescriptions', () {}),
      _QuickAction(Icons.notifications, 'Notifications', () {}),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildActionCard(a),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line),
        ),
        child: Column(
          children: [
            Icon(action.icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(this.icon, this.label, this.onTap);
}
