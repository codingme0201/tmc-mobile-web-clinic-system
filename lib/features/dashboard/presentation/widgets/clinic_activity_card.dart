import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/clinic_activity.dart';

class ClinicActivityCard extends StatelessWidget {
  final List<ClinicActivity> activities;
  final VoidCallback? onTap;

  const ClinicActivityCard({
    super.key,
    required this.activities,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                const Icon(Icons.campaign_outlined, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Clinic Activity',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.mutedLight, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No clinic activities available.',
                  style: TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
              )
            else
              ...activities.take(3).map((a) => _buildActivityItem(a)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ClinicActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeBadge(activity.type),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    switch (type) {
      case 'Health Program':
        color = AppTheme.success;
      case 'Announcement':
        color = AppTheme.info;
      case 'Event':
        color = AppTheme.gold;
      default:
        color = AppTheme.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
