import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../controllers/clinic_information_controller.dart';
import '../../domain/models/clinic_schedule.dart';

class ClinicScheduleScreen extends StatelessWidget {
  const ClinicScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Schedule')),
      body: Consumer<ClinicInformationController>(
        builder: (context, controller, _) {
          if (controller.status == ClinicInfoStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final schedule = controller.data?.clinicSchedule;
          if (schedule == null) {
            return const Center(
              child: Text('No schedule data available.', style: TextStyle(color: AppTheme.muted)),
            );
          }

          final now = DateTime.now().weekday;
          final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSectionTitle('Weekly Schedule'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: schedule.weeklySchedule.map((day) {
                    final isToday = day.day == dayNames[now - 1];
                    return _buildScheduleRow(day, isToday);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.info.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppTheme.info),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Clinic hours may vary during holidays and university breaks. '
                        'Please check announcements for schedule changes.',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule, color: AppTheme.primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'TMC Student Health Clinic Operating Hours',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
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

  Widget _buildScheduleRow(DaySchedule day, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: isToday
          ? BoxDecoration(
              color: AppTheme.primary.withAlpha(10),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day.day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                color: isToday ? AppTheme.primary : AppTheme.ink,
              ),
            ),
          ),
          Expanded(
            child: day.isClosed
                ? const Text(
                    'Closed',
                    style: TextStyle(fontSize: 14, color: AppTheme.muted),
                  )
                : Text(
                    '${day.openTime} – ${day.closeTime}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.ink),
                  ),
          ),
          if (!day.isClosed)
            Icon(Icons.check_circle, size: 16, color: AppTheme.success.withAlpha(180))
          else
            Icon(Icons.cancel_outlined, size: 16, color: AppTheme.mutedLight),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: day.isClosed ? AppTheme.danger.withAlpha(20) : AppTheme.success.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: day.isClosed ? AppTheme.danger : AppTheme.success,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
