import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/widgets/empty_state.dart';
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
      appBar: AppBar(title: const Text('Appointment History')),
      body: Consumer<AppointmentController>(
        builder: (context, controller, _) {
          if (controller.status == AppointmentListStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (controller.status == AppointmentListStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                  const SizedBox(height: 16),
                  Text(
                    controller.error ?? 'Unable to load appointment history.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => controller.loadAppointments(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
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
                        message: _searchQuery.isNotEmpty || _selectedStatus != 'all'
                            ? 'No matching appointments found.'
                            : 'No appointment history yet.',
                        icon: Icons.history,
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.refreshAppointments(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search history...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.mutedLight, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
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
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.line),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusFilter(),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'value': 'all', 'label': 'All'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'cancelled', 'label': 'Cancelled'},
      {'value': 'noShow', 'label': 'No-Show'},
    ];

    return SizedBox(
      height: 32,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.line,
                ),
              ),
              child: Text(
                status['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailScreen(appointmentId: appointment.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(appointment.status),
                    color: _getStatusColor(appointment.status),
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
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(appointment.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.line),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.muted),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d, yyyy').format(appointment.date),
                  style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_outlined, size: 14, color: AppTheme.muted),
                const SizedBox(width: 6),
                Text(
                  appointment.time,
                  style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
              ],
            ),
            if (appointment.cancelReason != null &&
                appointment.cancelReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppTheme.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.cancelReason!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.danger),
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

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case AppointmentStatus.pending:
        backgroundColor = AppTheme.gold.withAlpha(30);
        textColor = const Color(0xFFB8860B);
        break;
      case AppointmentStatus.confirmed:
        backgroundColor = AppTheme.info.withAlpha(20);
        textColor = AppTheme.info;
        break;
      case AppointmentStatus.completed:
        backgroundColor = AppTheme.success.withAlpha(20);
        textColor = AppTheme.success;
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = AppTheme.danger.withAlpha(20);
        textColor = AppTheme.danger;
        break;
      case AppointmentStatus.noShow:
        backgroundColor = AppTheme.muted.withAlpha(20);
        textColor = AppTheme.muted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
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
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.noShow:
        return Icons.person_off_outlined;
    }
  }
}
