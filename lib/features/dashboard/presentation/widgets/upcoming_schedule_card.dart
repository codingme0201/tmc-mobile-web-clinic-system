import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/schedule_item.dart';

class UpcomingScheduleCard extends StatelessWidget {
  final List<ScheduleItem> items;

  const UpcomingScheduleCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.event_note, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Upcoming Schedule',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No upcoming schedules.',
                style: TextStyle(fontSize: 13, color: AppTheme.muted),
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
      dateLabel = 'Tomorrow';
    } else {
      dateLabel = '${item.date.day}/${item.date.month}';
    }

    IconData icon;
    Color iconColor;
    switch (item.type) {
      case ScheduleType.appointment:
        icon = Icons.calendar_today;
        iconColor = AppTheme.primary;
      case ScheduleType.clinicActivity:
        icon = Icons.campaign_outlined;
        iconColor = AppTheme.success;
      case ScheduleType.clinicSchedule:
        icon = Icons.schedule;
        iconColor = AppTheme.info;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: iconColor),
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.ink),
                ),
                if (item.time != null || item.description != null)
                  Text(
                    [if (item.time != null) item.time, if (item.description != null) item.description]
                        .join(' · '),
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
