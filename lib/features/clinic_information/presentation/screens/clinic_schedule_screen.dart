import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/clinic_information_controller.dart';
import '../../domain/models/clinic_schedule.dart';

class ClinicScheduleScreen extends StatelessWidget {
  const ClinicScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FACILITY SCHEDULE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Operating Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ClinicInformationController>(
        builder: (context, controller, _) {
          if (controller.status == ClinicInfoStatus.loading) {
            return const LoadingView(message: 'Loading clinic schedule...');
          }

          final schedule = controller.data?.clinicSchedule;
          if (schedule == null) {
            return const EmptyState(
              title: 'Schedule Unavailable',
              message: 'Clinic operating hours are currently being synchronized.',
              icon: Icons.event_busy_outlined,
            );
          }

          final now = DateTime.now().weekday;
          final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildSectionHeader('WEEKLY ROTATION', 'Clinic Operating Hours'),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.cardDecoration(radius: 18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: schedule.weeklySchedule.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    final isToday = day.day == dayNames[now - 1];
                    final isLast = index == schedule.weeklySchedule.length - 1;
                    return Column(
                      children: [
                        _buildScheduleRow(day, isToday),
                        if (!isLast) const Divider(height: 1, color: AppTheme.line),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withAlpha(25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Clinic hours may vary during holidays and university semester breaks. Please review the official announcements for sudden schedule changes.',
                        style: TextStyle(fontSize: 12, color: AppTheme.inkLight, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold, width: 1.5),
            ),
            child: const Icon(Icons.access_time_filled_rounded, color: AppTheme.goldLight, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TMC HEALTH SERVICES',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.goldLight,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Student Health Center Schedule',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String kicker, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 13,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              kicker,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow(DaySchedule day, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: isToday
          ? BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              day.day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                color: isToday ? AppTheme.primary : AppTheme.ink,
              ),
            ),
          ),
          Expanded(
            child: day.isClosed
                ? const Text(
                    'Closed',
                    style: TextStyle(fontSize: 13.5, color: AppTheme.muted, fontWeight: FontWeight.w500),
                  )
                : Text(
                    '${day.openTime} – ${day.closeTime}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                      color: isToday ? AppTheme.ink : AppTheme.inkLight,
                    ),
                  ),
          ),
          if (!day.isClosed)
            const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.success)
          else
            const Icon(Icons.cancel_rounded, size: 16, color: AppTheme.mutedLight),
          if (isToday) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: day.isClosed ? AppTheme.danger.withAlpha(20) : AppTheme.success.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: day.isClosed ? AppTheme.danger.withAlpha(50) : AppTheme.success.withAlpha(50),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: day.isClosed ? AppTheme.danger : AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: day.isClosed ? AppTheme.danger : AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

