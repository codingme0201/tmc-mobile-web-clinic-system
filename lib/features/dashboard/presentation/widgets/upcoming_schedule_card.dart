import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/schedule_item.dart';

class UpcomingScheduleCard extends StatelessWidget {
  final List<ScheduleItem> items;

  const UpcomingScheduleCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_note_rounded, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Upcoming Schedule',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.event_busy_rounded, size: 16, color: AppTheme.muted.withAlpha(150)),
                  const SizedBox(width: 8),
                  const Text(
                    'No upcoming schedules.',
                    style: TextStyle(fontSize: 13, color: AppTheme.muted),
                  ),
                ],
              ),
            )
          else
            ...items.take(5).map((item) => _buildScheduleItem(item)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    final now = DateTime.now();
    final difference = item.date.difference(now).inDays;

    String dateLabel;
    if (difference == 0) {
      dateLabel = 'Today';
    } else if (difference == 1) {
      dateLabel = 'Tmrw';
    } else {
      dateLabel = '${item.date.day}/${item.date.month}';
    }

    IconData icon;
    Color iconColor;
    switch (item.type) {
      case ScheduleType.appointment:
        icon = Icons.calendar_today_rounded;
        iconColor = AppTheme.primary;
      case ScheduleType.clinicActivity:
        icon = Icons.campaign_rounded;
        iconColor = AppTheme.success;
      case ScheduleType.clinicSchedule:
        icon = Icons.access_time_filled_rounded;
        iconColor = AppTheme.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: iconColor.withAlpha(40)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: iconColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.time != null || item.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [if (item.time != null) item.time, if (item.description != null) item.description]
                        .join(' · '),
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
