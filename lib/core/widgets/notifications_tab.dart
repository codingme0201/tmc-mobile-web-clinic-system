import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
import '../../features/notifications/domain/models/patient_notification.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().loadNotifications();
    });
  }

  IconData _getNotificationIcon(PatientNotification notif) {
    final cat = notif.category.toLowerCase();
    final type = notif.type.toLowerCase();

    if (cat.contains('appointment') || type.contains('appointment')) {
      return Icons.calendar_today_outlined;
    }
    if (cat.contains('certificate') || type.contains('certificate')) {
      return Icons.article_outlined;
    }
    if (cat.contains('prescription') || type.contains('prescription')) {
      return Icons.medication_outlined;
    }
    if (cat.contains('announcement') || cat.contains('campaign')) {
      return Icons.campaign_outlined;
    }
    if (cat.contains('consultation')) {
      return Icons.medical_services_outlined;
    }
    return Icons.notifications_outlined;
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NotificationController>(
        builder: (context, controller, _) {
          if (controller.status == NotificationListStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (controller.status == NotificationListStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                  const SizedBox(height: 16),
                  Text(
                    controller.error ?? 'Unable to load notifications.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => controller.loadNotifications(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final notifications = controller.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 56, color: AppTheme.mutedLight.withAlpha(100)),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You are all caught up!',
                    style: TextStyle(fontSize: 13, color: AppTheme.muted),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadNotifications(),
            color: AppTheme.primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (controller.unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.unreadCount} Unread',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.markAllAsRead(),
                          child: const Text('Mark all as read'),
                        ),
                      ],
                    ),
                  ),
                ...notifications.map((notif) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        if (!notif.isRead) {
                          controller.markAsRead(notif.id);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration(
                          color: notif.isRead ? Colors.white : const Color(0xFFF2FAF8),
                          borderRadius: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: notif.isRead ? AppTheme.surfaceSubtle : AppTheme.primaryLight.withAlpha(22),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: notif.isRead ? AppTheme.line : AppTheme.primaryLight.withAlpha(50),
                                ),
                              ),
                              child: Icon(
                                _getNotificationIcon(notif),
                                color: notif.isRead ? AppTheme.muted : AppTheme.primary,
                                size: 20,
                              ),
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
                                          notif.title,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                            color: AppTheme.ink,
                                          ),
                                        ),
                                      ),
                                      if (!notif.isRead)
                                        Container(
                                          width: 7,
                                          height: 7,
                                          margin: const EdgeInsets.only(left: 6),
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.message,
                                    style: const TextStyle(fontSize: 12.5, color: AppTheme.muted, height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(notif.createdAt),
                                        style: const TextStyle(fontSize: 11, color: AppTheme.mutedLight, fontWeight: FontWeight.w500),
                                      ),
                                      if (notif.source.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withAlpha(12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            notif.source,
                                            style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
