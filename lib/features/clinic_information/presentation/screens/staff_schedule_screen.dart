import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../controllers/clinic_information_controller.dart';
import '../../domain/models/staff_schedule.dart';

class StaffScheduleScreen extends StatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  StaffRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor / Nurse Schedule')),
      body: Consumer<ClinicInformationController>(
        builder: (context, controller, _) {
          if (controller.status == ClinicInfoStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final staff = controller.data?.staffSchedules;
          if (staff == null || staff.isEmpty) {
            return const Center(
              child: Text('No staff schedule data available.', style: TextStyle(color: AppTheme.muted)),
            );
          }

          final filtered = _selectedRole == null
              ? staff
              : staff.where((s) => s.role == _selectedRole).toList();

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No staff found for this filter.', style: TextStyle(color: AppTheme.muted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildStaffCard(filtered[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          _buildFilterChip('Doctors', StaffRole.doctor),
          const SizedBox(width: 8),
          _buildFilterChip('Nurses', StaffRole.nurse),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StaffRole? role) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffSchedule staff) {
    final isDoctor = staff.role == StaffRole.doctor;

    return Container(
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
              CircleAvatar(
                radius: 22,
                backgroundColor: isDoctor
                    ? AppTheme.primary.withAlpha(25)
                    : AppTheme.info.withAlpha(25),
                child: Icon(
                  isDoctor ? Icons.person : Icons.medical_services,
                  color: isDoctor ? AppTheme.primary : AppTheme.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staff.specialty,
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              _buildRoleBadge(isDoctor ? 'Doctor' : 'Nurse', isDoctor),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.line),
          const SizedBox(height: 10),
          ...staff.schedule.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppTheme.mutedLight),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        entry.day,
                        style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                    ),
                    Text(
                      '${entry.startTime} – ${entry.endTime}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.ink),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String label, bool isDoctor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDoctor ? AppTheme.primary.withAlpha(20) : AppTheme.info.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDoctor ? AppTheme.primary : AppTheme.info,
        ),
      ),
    );
  }
}
