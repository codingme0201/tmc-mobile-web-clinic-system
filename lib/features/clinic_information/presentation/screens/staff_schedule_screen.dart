import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_view.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CLINICAL PRACTITIONERS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Doctor & Nurse Roster',
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
            return const LoadingView(message: 'Loading practitioner schedules...');
          }

          final staff = controller.data?.staffSchedules;
          if (staff == null || staff.isEmpty) {
            return const EmptyState(
              title: 'Roster Unavailable',
              message: 'No clinical practitioner schedule data is currently registered.',
              icon: Icons.people_outline_rounded,
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
                    ? const EmptyState(
                        title: 'No Staff Found',
                        message: 'No clinical practitioners match the selected filter.',
                        icon: Icons.person_search_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Row(
        children: [
          _buildFilterChip('All Staff', null),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : const Color(0xFFF4F7F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : AppTheme.line),
          boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffSchedule staff) {
    final isDoctor = staff.role == StaffRole.doctor;
    final primaryColor = isDoctor ? AppTheme.primary : AppTheme.info;

    return Container(
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDoctor ? AppTheme.gold : AppTheme.info.withAlpha(120),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: primaryColor.withAlpha(20),
                    child: Icon(
                      isDoctor ? Icons.medical_services_rounded : Icons.health_and_safety_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
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
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        staff.specialty,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                _buildRoleBadge(isDoctor ? 'Physician' : 'Nurse', isDoctor),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.line),
              ),
              child: Column(
                children: staff.schedule.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == staff.schedule.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 86,
                          child: Text(
                            item.day,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.inkLight),
                          ),
                        ),
                        Text(
                          '${item.startTime} – ${item.endTime}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String label, bool isDoctor) {
    final color = isDoctor ? AppTheme.primary : AppTheme.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
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
}

