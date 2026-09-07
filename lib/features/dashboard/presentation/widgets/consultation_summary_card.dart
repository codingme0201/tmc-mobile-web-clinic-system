import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class ConsultationSummaryCard extends StatelessWidget {
  final int scheduled;
  final int completed;
  final VoidCallback? onTap;

  const ConsultationSummaryCard({
    super.key,
    required this.scheduled,
    required this.completed,
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
                const Icon(Icons.medical_information_outlined, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Consultations',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.mutedLight, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildStat('Scheduled', scheduled, AppTheme.primary),
                const SizedBox(width: 24),
                _buildStat('Completed', completed, AppTheme.success),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(fontSize: 11, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
