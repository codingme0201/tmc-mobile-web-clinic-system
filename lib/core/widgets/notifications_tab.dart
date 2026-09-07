import 'package:flutter/material.dart';
import '../../app/theme.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildNotificationCard(
          icon: Icons.calendar_today,
          title: 'Appointment Reminder',
          message: 'You have an upcoming appointment with Dr. Maria Santos tomorrow at 10:00 AM.',
          time: '2 hours ago',
          unread: true,
        ),
        const SizedBox(height: 12),
        _buildNotificationCard(
          icon: Icons.medical_information_outlined,
          title: 'Lab Results Available',
          message: 'Your blood test results from Aug 15 are now available for viewing.',
          time: '1 day ago',
          unread: true,
        ),
        const SizedBox(height: 12),
        _buildNotificationCard(
          icon: Icons.check_circle_outline,
          title: 'Appointment Confirmed',
          message: 'Your appointment with Dr. Angelo Cruz on Sep 10 has been confirmed.',
          time: '3 days ago',
          unread: false,
        ),
        const SizedBox(height: 12),
        _buildNotificationCard(
          icon: Icons.campaign_outlined,
          title: 'Clinic Announcement',
          message: 'Free flu vaccination drive on Sep 12. Walk-ins welcome.',
          time: '5 days ago',
          unread: false,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool unread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread ? AppTheme.primary.withAlpha(8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unread ? AppTheme.primary.withAlpha(40) : AppTheme.line,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: unread ? AppTheme.primary.withAlpha(20) : AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: unread ? AppTheme.primary : AppTheme.muted, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
