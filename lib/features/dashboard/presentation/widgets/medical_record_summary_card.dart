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
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_shared_rounded, color: AppTheme.gold, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Medical Records',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getInk(context),
                    ),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceSubtle(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.getMuted(context), size: 11),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.getMuted(context).withAlpha(150)),
                    const SizedBox(width: 8),
                    Text(
                      'No recent medical record information.',
                      style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context)),
                    ),
                  ],
                ),
              )
            else
              ...records.take(3).map((r) => _buildRecordItem(context, r)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, MedicalRecord record) {
    final isDark = AppTheme.isDark(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceSubtle(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getLine(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.primary.withAlpha(45) : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (record.summary != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.summary!,
                    style: TextStyle(fontSize: 11, color: AppTheme.getMuted(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.getMutedLight(context)),
        ],
      ),
    );
  }
}
