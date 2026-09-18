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
              'SCHEDULE REVISION',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Reschedule Visit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCurrentAppointmentCard(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cardDecoration(context: context, radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('SELECT NEW DATE', 'Choose Rescheduled Date'),
                const SizedBox(height: 12),
                _buildDatePicker(),
                const SizedBox(height: 22),
                _buildSectionHeader('SELECT NEW TIME', 'Choose Available Window'),
                const SizedBox(height: 12),
                _buildTimeSlotGrid(),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Confirm Reschedule',
            icon: Icons.event_repeat_rounded,
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
      decoration: AppTheme.cardDecoration(context: context, radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              border: Border(bottom: BorderSide(color: AppTheme.getLine(context))),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_note_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'CURRENT SCHEDULED VISIT',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appointment.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getInk(context),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_month_outlined,
                  'Date',
                  DateFormat('EEEE, MMM d, yyyy').format(widget.appointment.date),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.schedule_rounded,
                  'Time',
                  widget.appointment.time,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person_outline_rounded,
                  'Doctor',
                  widget.appointment.doctorName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String kicker, String title) {
    final ink = AppTheme.getInk(context);

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
            color: ink,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final subtleBg = AppTheme.getSurfaceSubtle(context);
    final line = AppTheme.getLine(context);
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);
    final mutedLight = AppTheme.getMutedLight(context);

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final isDark = AppTheme.isDark(context);
        final picked = await showDatePicker(
          context: context,
          initialDate: _newDate ?? now.add(const Duration(days: 1)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: AppTheme.primary,
                        onPrimary: Colors.white,
                        surface: AppTheme.darkSurface,
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: AppTheme.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppTheme.ink,
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
          color: subtleBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _newDate == null ? line : AppTheme.primary,
            width: _newDate == null ? 1 : 1.5,
          ),
          boxShadow: AppTheme.cardShadowSubtle,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: _newDate != null ? AppTheme.primary : muted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _newDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_newDate!)
                    : 'Select new date...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _newDate != null ? FontWeight.w600 : FontWeight.normal,
                  color: _newDate != null ? ink : mutedLight,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    final subtleBg = AppTheme.getSurfaceSubtle(context);
    final line = AppTheme.getLine(context);
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected ? null : subtleBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : line,
              ),
              boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: isSelected ? Colors.white : muted,
                ),
                const SizedBox(width: 6),
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : ink,
                  ),
                ),
              ],
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

