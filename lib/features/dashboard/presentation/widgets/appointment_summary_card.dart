import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class AppointmentSummaryCard extends StatelessWidget {
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final VoidCallback? onTap;

  const AppointmentSummaryCard({
    super.key,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
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
                const Icon(Icons.calendar_today, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Appointments',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.mutedLight, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildStat('Pending', pending, AppTheme.warning),
                const SizedBox(width: 12),
                _buildStat('Confirmed', confirmed, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat('Completed', completed, AppTheme.success),
                const SizedBox(width: 12),
                _buildStat('Cancelled', cancelled, AppTheme.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
