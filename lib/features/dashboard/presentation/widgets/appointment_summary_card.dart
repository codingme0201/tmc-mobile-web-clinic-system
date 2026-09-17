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
                  child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Appointments',
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
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStat('Pending', pending, AppTheme.warning),
                const SizedBox(width: 8),
                _buildStat('Confirmed', confirmed, AppTheme.primary),
                const SizedBox(width: 8),
                _buildStat('Completed', completed, AppTheme.success),
                const SizedBox(width: 8),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withAlpha(210),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
