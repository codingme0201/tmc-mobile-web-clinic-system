import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/appointment_controller.dart';

class RequestAppointmentScreen extends StatefulWidget {
  const RequestAppointmentScreen({super.key});

  @override
  State<RequestAppointmentScreen> createState() =>
      _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends State<RequestAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDoctor;
  String? _selectedType;
  bool _isSubmitting = false;
  bool _showReview = false;

  late List<String> _availableTimeSlots;
  late List<String> _doctorNames;
  late List<String> _appointmentTypes;

  @override
  void initState() {
    super.initState();
    final controller = context.read<AppointmentController>();
    _availableTimeSlots = controller.getAvailableTimeSlots();
    _doctorNames = controller.getDoctorNames();
    _appointmentTypes = controller.getAppointmentTypes();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
          onPressed: () {
            if (_showReview) {
              setState(() {
                _showReview = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONSULTATION BOOKING',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _showReview ? 'Review Appointment' : 'Schedule Appointment',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: _showReview ? _buildReviewStep() : _buildFormStep(),
    );
  }

  Widget _buildFormStep() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cardDecoration(context: context, radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('APPOINTMENT TYPE', 'Select Consultation Category'),
                const SizedBox(height: 12),
                _buildTypeDropdown(),
                const SizedBox(height: 22),
                _buildSectionHeader('CONSULTATION DATE', 'Choose Preferred Day'),
                const SizedBox(height: 12),
                _buildDatePicker(),
                const SizedBox(height: 22),
                _buildSectionHeader('TIME SLOT', 'Select Available Window'),
                const SizedBox(height: 12),
                _buildTimeSlotGrid(),
                const SizedBox(height: 22),
                _buildSectionHeader('ATTENDING PHYSICIAN', 'Choose Doctor / Specialist'),
                const SizedBox(height: 12),
                _buildDoctorDropdown(),
                const SizedBox(height: 22),
                _buildSectionHeader('CLINICAL REASON', 'Describe Your Symptoms or Request'),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Reason for visit',
                  controller: _reasonController,
                  hintText: 'Please describe symptoms, existing conditions, or visit reason...',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a reason for your appointment.';
                    }
                    if (value.trim().length < 5) {
                      return 'Please provide a more detailed reason.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Review & Confirm',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _validateAndReview,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: AppTheme.cardDecoration(context: context, radius: 20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: AppTheme.heroGradient,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: AppTheme.goldLight, size: 22),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONFIRMATION PREVIEW',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.goldLight,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Appointment Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildReviewRow('Type', _selectedType ?? '', Icons.medical_services_outlined),
                    Divider(height: 24, color: AppTheme.getLine(context)),
                    _buildReviewRow('Date', dateFormat.format(_selectedDate!), Icons.calendar_month_outlined),
                    Divider(height: 24, color: AppTheme.getLine(context)),
                    _buildReviewRow('Time', _selectedTime ?? '', Icons.schedule_rounded),
                    Divider(height: 24, color: AppTheme.getLine(context)),
                    _buildReviewRow('Doctor', _selectedDoctor ?? '', Icons.person_outline_rounded),
                    Divider(height: 24, color: AppTheme.getLine(context)),
                    _buildReviewRow('Reason', _reasonController.text.trim(), Icons.edit_note_rounded),
                    Divider(height: 24, color: AppTheme.getLine(context)),
                    _buildReviewRow('Status', 'Pending Approval', Icons.hourglass_top_rounded, valueColor: AppTheme.gold),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _showReview = false;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurface(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.getLine(context)),
                    ),
                    child: Center(
                      child: Text(
                        'Edit Details',
                        style: TextStyle(
                          color: AppTheme.getInk(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Submit Request',
                isLoading: _isSubmitting,
                icon: Icons.send_rounded,
                onPressed: _submitAppointment,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, IconData icon, {Color? valueColor}) {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? ink,
              ),
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

  Widget _buildTypeDropdown() {
    final surface = AppTheme.getSurface(context);
    final subtleBg = AppTheme.getSurfaceSubtle(context);
    final line = AppTheme.getLine(context);
    final ink = AppTheme.getInk(context);
    final mutedLight = AppTheme.getMutedLight(context);

    return Container(
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedType,
        dropdownColor: surface,
        style: TextStyle(color: ink, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.medical_services_outlined, color: AppTheme.primary, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          filled: true,
          fillColor: subtleBg,
        ),
        hint: Text('Select appointment type', style: TextStyle(fontSize: 13.5, color: mutedLight)),
        items: _appointmentTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedType = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an appointment type.';
          }
          return null;
        },
      ),
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
          initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
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
            _selectedDate = picked;
            if (_selectedTime != null && _isSlotOccupied(_selectedTime!)) {
              _selectedTime = null;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: subtleBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedDate == null ? line : AppTheme.primary,
            width: _selectedDate == null ? 1 : 1.5,
          ),
          boxShadow: AppTheme.cardShadowSubtle,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: _selectedDate != null ? AppTheme.primary : muted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                    : 'Choose appointment date...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                  color: _selectedDate != null ? ink : mutedLight,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }

  String _normalizeTime(String raw) {
    final clean = raw.trim().toUpperCase();
    try {
      if (clean.contains('AM') || clean.contains('PM')) {
        final parsed = DateFormat('hh:mm a').parse(clean);
        return DateFormat('hh:mm a').format(parsed);
      } else {
        final parts = clean.split(':');
        if (parts.length >= 2) {
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final dummy = DateTime(2000, 1, 1, h, m);
          return DateFormat('hh:mm a').format(dummy);
        }
      }
    } catch (_) {}
    return clean;
  }

  bool _isSlotOccupied(String slot) {
    if (_selectedDate == null) return false;
    final controller = context.read<AppointmentController>();
    final normSlot = _normalizeTime(slot);

    return controller.appointments.any((a) {
      if (a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.noShow) {
        return false;
      }
      final sameDate = a.date.year == _selectedDate!.year &&
          a.date.month == _selectedDate!.month &&
          a.date.day == _selectedDate!.day;
      if (!sameDate) return false;
      return _normalizeTime(a.time) == normSlot;
    });
  }

  Widget _buildTimeSlotGrid() {
    final subtleBg = AppTheme.getSurfaceSubtle(context);
    final line = AppTheme.getLine(context);
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTimeSlots.map((slot) {
            final isOccupied = _isSlotOccupied(slot);
            final isSelected = _selectedTime == slot;

            return GestureDetector(
              onTap: isOccupied
                  ? () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('The $slot slot on this date is already booked. Please pick another time.'),
                          backgroundColor: AppTheme.warning,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : () {
                      setState(() {
                        _selectedTime = slot;
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected
                      ? null
                      : isOccupied
                          ? (AppTheme.isDark(context) ? const Color(0xFF202525) : const Color(0xFFF1F3F4))
                          : subtleBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : isOccupied
                            ? (AppTheme.isDark(context) ? Colors.white10 : Colors.black12)
                            : line,
                  ),
                  boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOccupied ? Icons.block_rounded : Icons.schedule_rounded,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : isOccupied
                              ? AppTheme.danger.withAlpha(160)
                              : muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isOccupied
                                ? muted.withAlpha(140)
                                : ink,
                        decoration: isOccupied ? TextDecoration.lineThrough : null,
                        decorationColor: AppTheme.danger.withAlpha(180),
                      ),
                    ),
                    if (isOccupied) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(Booked)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.danger.withAlpha(200),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedDate != null && _availableTimeSlots.any(_isSlotOccupied)) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.warning),
              const SizedBox(width: 6),
              Text(
                'Crossed-out slots have already been reserved for this day.',
                style: TextStyle(fontSize: 11.5, color: muted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDoctorDropdown() {
    final surface = AppTheme.getSurface(context);
    final subtleBg = AppTheme.getSurfaceSubtle(context);
    final line = AppTheme.getLine(context);
    final ink = AppTheme.getInk(context);
    final mutedLight = AppTheme.getMutedLight(context);

    return Container(
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedDoctor,
        dropdownColor: surface,
        style: TextStyle(color: ink, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primary, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          filled: true,
          fillColor: subtleBg,
        ),
        hint: Text('Select a doctor or physician', style: TextStyle(fontSize: 13.5, color: mutedLight)),
        items: _doctorNames.map((name) {
          return DropdownMenuItem(
            value: name,
            child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDoctor = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a doctor.';
          }
          return null;
        },
      ),
    );
  }

  void _validateAndReview() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      if (_isSlotOccupied(_selectedTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The selected time slot is already booked. Please choose an available slot.'),
            backgroundColor: AppTheme.danger,
          ),
        );
        return;
      }
      setState(() {
        _showReview = true;
      });
    } else {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an appointment date.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      } else if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an appointment time slot.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _submitAppointment() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final controller = context.read<AppointmentController>();
    final result = await controller.createAppointment(
      title: _selectedType!,
      reason: _reasonController.text.trim(),
      date: _selectedDate!,
      time: _selectedTime!,
      doctorName: _selectedDoctor!,
      type: _selectedType!,
      clinic: 'TMC Student Health Clinic',
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment request submitted successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.error ?? 'Failed to submit appointment.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}

