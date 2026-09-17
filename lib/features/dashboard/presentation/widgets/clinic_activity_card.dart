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
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: AppTheme.success, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Clinic Activity',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.muted, size: 11),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.event_note_outlined, size: 16, color: AppTheme.muted.withAlpha(150)),
                    const SizedBox(width: 8),
                    const Text(
                      'No clinic activities available.',
                      style: TextStyle(fontSize: 13, color: AppTheme.muted),
                    ),
                  ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeBadge(activity.type),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            activity.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              activity.description,
              style: const TextStyle(fontSize: 11.5, color: AppTheme.muted, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
        color = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            type,
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
