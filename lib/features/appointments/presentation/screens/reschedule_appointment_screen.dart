import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/appointment_controller.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const RescheduleAppointmentScreen({super.key, required this.appointment});

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  DateTime? _newDate;
  String? _newTime;
  bool _isSubmitting = false;

  late List<String> _availableTimeSlots;

  @override
  void initState() {
    super.initState();
    final controller = context.read<AppointmentController>();
    _availableTimeSlots = controller.getAvailableTimeSlots();
    _newDate = widget.appointment.date;
    _newTime = widget.appointment.time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reschedule Appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCurrentAppointmentCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('New Date'),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildSectionTitle('New Time'),
          const SizedBox(height: 12),
          _buildTimeSlotGrid(),
          const SizedBox(height: 32),
          AppButton(
            label: 'Confirm Reschedule',
            isLoading: _isSubmitting,
            onPressed: _rescheduleAppointment,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCurrentAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.muted.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Appointment',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Date',
            DateFormat('MMM d, yyyy').format(widget.appointment.date),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time_outlined,
            'Time',
            widget.appointment.time,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.person_outline,
            'Doctor',
            widget.appointment.doctorName,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.muted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppTheme.muted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.ink,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _newDate ?? now.add(const Duration(days: 1)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.primary,
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _newDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppTheme.muted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _newDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_newDate!)
                    : 'Select new date',
                style: TextStyle(
                  fontSize: 14,
                  color: _newDate != null ? AppTheme.ink : AppTheme.muted,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTimeSlots.map((slot) {
        final isSelected = _newTime == slot;
        return GestureDetector(
          onTap: () {
            setState(() {
              _newTime = slot;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.line,
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.ink,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _rescheduleAppointment() async {
    if (_newDate == null || _newTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a new date and time.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (_newDate == widget.appointment.date &&
        _newTime == widget.appointment.time) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a different date or time.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final controller = context.read<AppointmentController>();
    final result = await controller.rescheduleAppointment(
      widget.appointment.id,
      _newDate!,
      _newTime!,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rescheduled successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.error ?? 'Failed to reschedule appointment.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}
