import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../controllers/clinic_information_controller.dart';
import '../../domain/models/clinic_information.dart';
import '../../domain/models/clinic_schedule.dart';

class ClinicInformationScreen extends StatefulWidget {
  const ClinicInformationScreen({super.key});

  @override
  State<ClinicInformationScreen> createState() => _ClinicInformationScreenState();
}

class _ClinicInformationScreenState extends State<ClinicInformationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicInformationController>().loadClinicInformation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Information')),
      body: Consumer<ClinicInformationController>(
        builder: (context, controller, _) {
          switch (controller.status) {
            case ClinicInfoStatus.initial:
            case ClinicInfoStatus.loading:
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            case ClinicInfoStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                    const SizedBox(height: 16),
                    Text(
                      controller.error ?? 'Unable to load clinic information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.getMuted(context), fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => controller.loadClinicInformation(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            case ClinicInfoStatus.loaded:
              final data = controller.data;
              if (data == null) {
                return Center(
                  child: Text('No clinic data.', style: TextStyle(color: AppTheme.getMuted(context))),
                );
              }
              return _buildContent(context, data);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClinicInformation data) {
    final info = data;
    final schedule = data.schedule;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildClinicHeader(info.name, info.description),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Contact Information'),
        const SizedBox(height: 12),
        _buildInfoCard(context, [
          _buildInfoRow(context, Icons.location_on_outlined, 'Address', info.address),
          Divider(height: 1, color: AppTheme.getLine(context)),
          _buildInfoRow(context, Icons.phone_android_rounded, 'Mobile Hotline', '+63 917 123 4567'),
          Divider(height: 1, color: AppTheme.getLine(context)),
          _buildInfoRow(context, Icons.phone_outlined, 'Telephone (Landline)', info.contactNumber),
          Divider(height: 1, color: AppTheme.getLine(context)),
          _buildInfoRow(context, Icons.email_outlined, 'Email', info.email),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Services'),
        const SizedBox(height: 12),
        _buildServicesCard(context, info.services),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Operating Hours'),
        const SizedBox(height: 12),
        _buildSchedulePreview(context, schedule),
        const SizedBox(height: 16),
        _buildViewAllButton(
          context,
          label: 'View Full Schedule',
          onTap: () => Navigator.pushNamed(context, '/clinic-schedule'),
        ),
        const SizedBox(height: 24),
        _buildNavigationCard(
          context,
          icon: Icons.people_outline,
          title: 'Doctor / Nurse Schedule',
          subtitle: 'View staff availability and schedules',
          onTap: () => Navigator.pushNamed(context, '/staff-schedule'),
        ),
        const SizedBox(height: 12),
        _buildNavigationCard(
          context,
          icon: Icons.campaign_outlined,
          title: 'Clinic Activities',
          subtitle: 'View upcoming events and announcements',
          onTap: () => Navigator.pushNamed(context, '/clinic-activities'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildClinicHeader(String name, String description) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 2),
                  color: Colors.white.withAlpha(35),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withAlpha(220),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.getInk(context),
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13.5, color: AppTheme.getMuted(context))),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, List<String> services) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: services.map((s) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withAlpha(35)),
            ),
            child: Text(
              s,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSchedulePreview(BuildContext context, ClinicSchedule? schedule) {
    if (schedule == null) {
      return Center(
        child: Text('No schedule available.', style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context))),
      );
    }
    final now = DateTime.now().weekday;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Container(
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
      child: Column(
        children: schedule.weeklySchedule.take(5).map((day) {
          final isToday = day.day == dayNames[now - 1];
          return _buildScheduleRow(context, day, isToday);
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context, DaySchedule day, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isToday
          ? BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              day.day.substring(0, 3),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                color: isToday ? AppTheme.primary : AppTheme.getInk(context),
              ),
            ),
          ),
          Expanded(
            child: day.isClosed
                ? Text(
                    'Closed',
                    style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context)),
                  )
                : Text(
                    '${day.openTime} – ${day.closeTime}',
                    style: TextStyle(fontSize: 13, color: AppTheme.getInk(context), fontWeight: FontWeight.w500),
                  ),
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: day.isClosed ? AppTheme.danger.withAlpha(20) : AppTheme.success.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                day.isClosed ? 'Closed' : 'Today',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: day.isClosed ? AppTheme.danger : AppTheme.success,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context, {required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.schedule_rounded, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.getInk(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context))),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceSubtle(context),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.getMuted(context), size: 11),
            ),
          ],
        ),
      ),
    );
  }
}
