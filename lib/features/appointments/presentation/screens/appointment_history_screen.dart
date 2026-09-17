import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/appointment_controller.dart';
import 'appointment_detail_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APPOINTMENT ARCHIVE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Appointment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AppointmentController>(
        builder: (context, controller, _) {
          if (controller.status == AppointmentListStatus.loading) {
            return const LoadingView(message: 'Loading appointment archive...');
          }

          if (controller.status == AppointmentListStatus.error) {
            return ErrorState(
              title: 'History Unavailable',
              message: controller.error ?? 'Unable to load appointment history.',
              onRetry: () => controller.loadAppointments(),
            );
          }

          var history = controller.appointmentHistory;

          if (_searchQuery.isNotEmpty) {
            history = history.where((a) {
              return a.title.toLowerCase().contains(_searchQuery) ||
                  a.reason.toLowerCase().contains(_searchQuery) ||
                  a.doctorName.toLowerCase().contains(_searchQuery) ||
                  a.type.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          if (_selectedStatus != 'all') {
            history = history.where((a) => a.status.name == _selectedStatus).toList();
          }

          return Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: history.isEmpty
                    ? EmptyState(
                        title: 'No Records Found',
                        message: _searchQuery.isNotEmpty || _selectedStatus != 'all'
                            ? 'No appointments match your search filter criteria.'
                            : 'No appointment history recorded in this account yet.',
                        icon: Icons.history_edu_outlined,
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: () => controller.refreshAppointments(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(context, history[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.cardShadowSubtle,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by doctor, type, or reason...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.mutedLight),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.muted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
                filled: true,
                fillColor: const Color(0xFFFCFDFD),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildStatusFilter(),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'value': 'all', 'label': 'All Records'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'cancelled', 'label': 'Cancelled'},
      {'value': 'noShow', 'label': 'No-Show'},
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status['value'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status['value']!;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : const Color(0xFFF4F7F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.line,
                ),
                boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
              ),
              child: Text(
                status['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Appointment appointment) {
    final statusColor = _getStatusColor(appointment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AppointmentDetailScreen(appointmentId: appointment.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withAlpha(35),
                            statusColor.withAlpha(12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withAlpha(50),
                        ),
                      ),
                      child: Icon(
                        _getStatusIcon(appointment.status),
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 13, color: AppTheme.muted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  appointment.doctorName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.muted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(appointment.status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, yyyy').format(appointment.date),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.inkLight,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        appointment.time,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.inkLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.cancelReason != null &&
                    appointment.cancelReason!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withAlpha(12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.danger.withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.danger),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Reason: ${appointment.cancelReason!}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.danger,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color color;

    switch (status) {
      case AppointmentStatus.pending:
        color = AppTheme.gold;
        break;
      case AppointmentStatus.confirmed:
        color = AppTheme.info;
        break;
      case AppointmentStatus.completed:
        color = AppTheme.success;
        break;
      case AppointmentStatus.cancelled:
        color = AppTheme.danger;
        break;
      case AppointmentStatus.noShow:
        color = AppTheme.muted;
        break;
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
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppTheme.gold;
      case AppointmentStatus.confirmed:
        return AppTheme.info;
      case AppointmentStatus.completed:
        return AppTheme.success;
      case AppointmentStatus.cancelled:
        return AppTheme.danger;
      case AppointmentStatus.noShow:
        return AppTheme.muted;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.schedule_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.completed:
        return Icons.task_alt_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.noShow:
        return Icons.person_off_outlined;
    }
  }
}

