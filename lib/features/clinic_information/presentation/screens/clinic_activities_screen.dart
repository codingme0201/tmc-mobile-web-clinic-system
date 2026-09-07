import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../controllers/clinic_information_controller.dart';
import '../../domain/models/clinic_activity_detail.dart';

class ClinicActivitiesScreen extends StatelessWidget {
  const ClinicActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Activities')),
      body: Consumer<ClinicInformationController>(
        builder: (context, controller, _) {
          if (controller.status == ClinicInfoStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final activities = controller.data?.activities;
          if (activities == null || activities.isEmpty) {
            return const Center(
              child: Text(
                'No clinic activities available at this time.',
                style: TextStyle(color: AppTheme.muted),
              ),
            );
          }

          final upcoming = activities.where((a) => a.status == ActivityStatus.upcoming).toList();
          final completed = activities.where((a) => a.status == ActivityStatus.completed).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (upcoming.isNotEmpty) ...[
                _buildSectionTitle('Upcoming'),
                const SizedBox(height: 12),
                ...upcoming.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActivityCard(a),
                    )),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSectionTitle('Past Activities'),
                const SizedBox(height: 12),
                ...completed.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActivityCard(a),
                    )),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
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

  Widget _buildActivityCard(ClinicActivityDetail activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              _buildStatusBadge(activity.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            activity.description,
            style: const TextStyle(fontSize: 13, color: AppTheme.muted, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.line),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.mutedLight),
              const SizedBox(width: 6),
              Text(
                _formatDate(activity.date),
                style: const TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
              if (activity.time != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: AppTheme.mutedLight),
                const SizedBox(width: 6),
                Text(
                  activity.time!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ],
          ),
          if (activity.location != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.mutedLight),
                const SizedBox(width: 6),
                Text(
                  activity.location!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ActivityStatus status) {
    Color color;
    String label;

    switch (status) {
      case ActivityStatus.upcoming:
        color = AppTheme.info;
        label = 'Upcoming';
      case ActivityStatus.ongoing:
        color = AppTheme.success;
        label = 'Ongoing';
      case ActivityStatus.completed:
        color = AppTheme.muted;
        label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
