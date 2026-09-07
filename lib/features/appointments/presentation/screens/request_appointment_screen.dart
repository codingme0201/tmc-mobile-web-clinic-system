import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
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
      appBar: AppBar(
        title: Text(_showReview ? 'Review Appointment' : 'Request Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
          _buildSectionTitle('Appointment Type'),
          const SizedBox(height: 12),
          _buildTypeDropdown(),
          const SizedBox(height: 20),
          _buildSectionTitle('Select Date'),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildSectionTitle('Select Time'),
          const SizedBox(height: 12),
          _buildTimeSlotGrid(),
          const SizedBox(height: 20),
          _buildSectionTitle('Doctor'),
          const SizedBox(height: 12),
          _buildDoctorDropdown(),
          const SizedBox(height: 20),
          _buildSectionTitle('Consultation Reason'),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Reason for visit',
            controller: _reasonController,
            hintText: 'Please briefly describe the reason for your appointment.',
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
          const SizedBox(height: 32),
          AppButton(
            label: 'Review Appointment',
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withAlpha(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Appointment Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildReviewRow('Type', _selectedType ?? ''),
              const SizedBox(height: 12),
              _buildReviewRow('Date', dateFormat.format(_selectedDate!)),
              const SizedBox(height: 12),
              _buildReviewRow('Time', _selectedTime ?? ''),
              const SizedBox(height: 12),
              _buildReviewRow('Doctor', _selectedDoctor ?? ''),
              const SizedBox(height: 12),
              _buildReviewRow('Reason', _reasonController.text.trim()),
              const SizedBox(height: 12),
              _buildReviewRow('Status', 'Pending'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _showReview = false;
                        });
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Submit Request',
                isLoading: _isSubmitting,
                onPressed: _submitAppointment,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.muted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.ink,
            ),
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

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      hint: const Text('Select appointment type'),
      items: _appointmentTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
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
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
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
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedDate == null ? AppTheme.line : AppTheme.primary,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppTheme.muted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                    : 'Select appointment date',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDate != null ? AppTheme.ink : AppTheme.muted,
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
        final isSelected = _selectedTime == slot;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = slot;
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

  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDoctor,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      hint: const Text('Select a doctor'),
      items: _doctorNames.map((name) {
        return DropdownMenuItem(
          value: name,
          child: Text(name),
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
    );
  }

  void _validateAndReview() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
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
            content: Text('Please select an appointment time.'),
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
