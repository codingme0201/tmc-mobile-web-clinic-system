import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/appointment.dart';
import '../controllers/appointment_controller.dart';
import 'reschedule_appointment_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  Appointment? _appointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    final controller = context.read<AppointmentController>();
    final appointment = await controller.getAppointmentById(widget.appointmentId);
    if (mounted) {
      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          if (_appointment != null &&
              (_appointment!.status == AppointmentStatus.pending ||
                  _appointment!.status == AppointmentStatus.confirmed))
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                if (_appointment!.status == AppointmentStatus.pending ||
                    _appointment!.status == AppointmentStatus.confirmed)
                  const PopupMenuItem(
                    value: 'reschedule',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 20, color: AppTheme.ink),
                        SizedBox(width: 12),
                        Text('Reschedule'),
                      ],
                    ),
                  ),
                if (_appointment!.status != AppointmentStatus.completed &&
                    _appointment!.status != AppointmentStatus.cancelled)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 20, color: AppTheme.danger),
                        SizedBox(width: 12),
                        Text('Cancel', style: TextStyle(color: AppTheme.danger)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _appointment == null
              ? const Center(
                  child: Text(
                    'Appointment not found.',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                )
              : _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    final appointment = _appointment!;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatusHeader(appointment),
        const SizedBox(height: 20),
        _buildSectionTitle('Appointment Information'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow(Icons.receipt_outlined, 'Reference', appointment.id.toUpperCase()),
          const Divider(height: 1),
          _buildInfoRow(Icons.category_outlined, 'Type', appointment.type),
          const Divider(height: 1),
          _buildInfoRow(Icons.local_hospital_outlined, 'Clinic', appointment.clinic),
        ]),
        const SizedBox(height: 20),
        _buildSectionTitle('Schedule'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow(Icons.calendar_today_outlined, 'Date', dateFormat.format(appointment.date)),
          const Divider(height: 1),
          _buildInfoRow(Icons.access_time_outlined, 'Time', appointment.time),
          const Divider(height: 1),
          _buildInfoRow(Icons.person_outline, 'Doctor', appointment.doctorName),
        ]),
        const SizedBox(height: 20),
        _buildSectionTitle('Consultation Reason'),
        const SizedBox(height: 12),
        _buildReasonCard(appointment.reason),
        if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionTitle('Notes'),
          const SizedBox(height: 12),
          _buildReasonCard(appointment.notes!),
        ],
        if (appointment.cancelReason != null &&
            appointment.cancelReason!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionTitle('Cancellation Reason'),
          const SizedBox(height: 12),
          _buildCancellationReasonCard(appointment.cancelReason!),
        ],
        const SizedBox(height: 20),
        _buildSectionTitle('Status'),
        const SizedBox(height: 12),
        _buildStatusCard(appointment.status),
        const SizedBox(height: 20),
        if (appointment.requestedOn != null) ...[
          _buildSectionTitle('Requested On'),
          const SizedBox(height: 12),
          Text(
            DateFormat('MMM d, yyyy \'at\' h:mm a').format(appointment.requestedOn!),
            style: const TextStyle(fontSize: 14, color: AppTheme.muted),
          ),
        ],
        if (appointment.updatedAt != null) ...[
          const SizedBox(height: 12),
          _buildSectionTitle('Last Updated'),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM d, yyyy \'at\' h:mm a').format(appointment.updatedAt!),
            style: const TextStyle(fontSize: 14, color: AppTheme.muted),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusHeader(Appointment appointment) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        backgroundColor = AppTheme.gold.withAlpha(30);
        textColor = const Color(0xFFB8860B);
        icon = Icons.schedule;
        break;
      case AppointmentStatus.confirmed:
        backgroundColor = AppTheme.info.withAlpha(20);
        textColor = AppTheme.info;
        icon = Icons.check_circle_outline;
        break;
      case AppointmentStatus.completed:
        backgroundColor = AppTheme.success.withAlpha(20);
        textColor = AppTheme.success;
        icon = Icons.check_circle;
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = AppTheme.danger.withAlpha(20);
        textColor = AppTheme.danger;
        icon = Icons.cancel_outlined;
        break;
      case AppointmentStatus.noShow:
        backgroundColor = AppTheme.muted.withAlpha(20);
        textColor = AppTheme.muted;
        icon = Icons.person_off_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.status.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.status.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.muted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.muted),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(
        reason,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.ink,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCancellationReasonCard(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withAlpha(50)),
      ),
      child: Text(
        reason,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.danger,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppointmentStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'reschedule':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RescheduleAppointmentScreen(
              appointment: _appointment!,
            ),
          ),
        );
        if (result == true) {
          _loadAppointment();
        }
        break;
      case 'cancel':
        _showCancelDialog();
        break;
    }
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this appointment? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Provide a reason for cancellation',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Appointment'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final controller = context.read<AppointmentController>();
              final messenger = ScaffoldMessenger.of(context);
              final result = await controller.cancelAppointment(
                _appointment!.id,
                reason: reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : null,
              );
              if (mounted) {
                if (result != null) {
                  setState(() {
                    _appointment = result;
                  });
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Appointment cancelled.'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(controller.error ?? 'Failed to cancel appointment.'),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Cancel Appointment',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}
