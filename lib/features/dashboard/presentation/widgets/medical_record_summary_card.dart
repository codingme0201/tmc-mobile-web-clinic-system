import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/medical_record.dart';

class MedicalRecordSummaryCard extends StatelessWidget {
  final List<MedicalRecord> records;
  final VoidCallback? onTap;

  const MedicalRecordSummaryCard({
    super.key,
    required this.records,
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
                const Icon(Icons.folder_outlined, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Medical Records',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.mutedLight, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No recent medical record information.',
                  style: TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
              )
            else
              ...records.take(3).map((r) => _buildRecordItem(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(MedicalRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(60),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.ink),
                ),
                if (record.summary != null)
                  Text(
                    record.summary!,
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
