import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/clinic_information_controller.dart';
import '../../domain/models/clinic_activity_detail.dart';

class ClinicActivitiesScreen extends StatelessWidget {
  const ClinicActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMMUNITY & WELLNESS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Clinic Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ClinicInformationController>(
        builder: (context, controller, _) {
          if (controller.status == ClinicInfoStatus.loading) {
            return const LoadingView(message: 'Loading clinic activities...');
          }

          final activities = controller.data?.activities;
          if (activities == null || activities.isEmpty) {
            return const EmptyState(
              title: 'No Current Activities',
              message: 'There are no active clinic campaigns or health events scheduled at this moment.',
              icon: Icons.campaign_outlined,
            );
          }

          final upcoming = activities.where((a) => a.status == ActivityStatus.upcoming).toList();
          final completed = activities.where((a) => a.status == ActivityStatus.completed).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (upcoming.isNotEmpty) ...[
                _buildSectionHeader(context, 'SCHEDULED CAMPAIGNS', 'Upcoming Events'),
                const SizedBox(height: 12),
                ...upcoming.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildActivityCard(context, a),
                    )),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSectionHeader(context, 'PAST HIGHLIGHTS', 'Concluded Activities'),
                const SizedBox(height: 12),
                ...completed.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildActivityCard(context, a),
                    )),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String kicker, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 13,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              kicker,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.getInk(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, ClinicActivityDetail activity) {
    return Container(
      decoration: AppTheme.cardDecoration(context: context, radius: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withAlpha(40)),
                  ),
                  child: const Center(
                    child: Icon(Icons.campaign_rounded, color: AppTheme.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getInk(context),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context), height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(activity.status),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceSubtle(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.getLine(context)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(activity.date),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.getInk(context)),
                  ),
                  if (activity.time != null) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      activity.time!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.getInk(context)),
                    ),
                  ],
                ],
              ),
            ),
            if (activity.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.gold),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      activity.location!,
                      style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ActivityStatus status) {
    Color color;
    String label;

    switch (status) {
      case ActivityStatus.upcoming:
        color = AppTheme.info;
        label = 'Upcoming';
      case ActivityStatus.ongoing:
        color = AppTheme.success;
        label = 'Ongoing';
      case ActivityStatus.completed:
        color = AppTheme.muted;
        label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(45)),
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
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

