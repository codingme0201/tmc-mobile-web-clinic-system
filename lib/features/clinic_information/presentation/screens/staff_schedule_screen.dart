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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ClinicInformationController>();
      if (controller.data == null && !controller.isLoading) {
        controller.loadClinicInformation();
      }
    });
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
              'Doctors & Nurses',
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
          final staff = controller.data?.staffSchedules;

          if (controller.isLoading && staff == null) {
            return const LoadingView(message: 'Loading doctors and nurses...');
          }

          if (staff == null || staff.isEmpty) {
            return EmptyState(
              title: 'No Doctors or Nurses Yet',
              message: controller.error ?? 'No doctor or nurse profiles are available right now.',
              icon: Icons.people_outline_rounded,
              actionLabel: 'Retry',
              onAction: controller.loadClinicInformation,
            );
          }

          final filtered = _selectedRole == null
              ? staff
              : staff.where((s) => s.role == _selectedRole).toList();

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadClinicInformation,
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(
                              title: 'No Staff Found',
                              message: 'No doctors or nurses match the selected filter.',
                              icon: Icons.person_search_outlined,
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildStaffCard(filtered[index]),
                          ),
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
      decoration: BoxDecoration(
        color: AppTheme.getSurface(context),
        border: Border(bottom: BorderSide(color: AppTheme.getLine(context))),
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
          color: isSelected ? null : AppTheme.getSurfaceSubtle(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : AppTheme.getLine(context)),
          boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.getMuted(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(StaffSchedule staff, {double radius = 22}) {
    final isDoctor = staff.role == StaffRole.doctor;
    final primaryColor = isDoctor ? AppTheme.primary : AppTheme.info;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDoctor ? AppTheme.gold : AppTheme.info.withAlpha(120),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: primaryColor.withAlpha(20),
        child: Icon(
          isDoctor ? Icons.medical_services_rounded : Icons.health_and_safety_rounded,
          color: primaryColor,
          size: radius,
        ),
      ),
    );
  }

  String _subtitle(StaffSchedule staff) {
    return [staff.position, staff.specialty].where((s) => s.isNotEmpty).join(' · ');
  }

  Widget _buildStaffCard(StaffSchedule staff) {
    final isDoctor = staff.role == StaffRole.doctor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showProfile(staff),
        child: Ink(
          decoration: AppTheme.cardDecoration(context: context, radius: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(staff),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  staff.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.getInk(context),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              if (staff.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, size: 16, color: AppTheme.success),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _subtitle(staff),
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.getMuted(context)),
                          ),
                        ],
                      ),
                    ),
                    _buildRoleBadge(isDoctor ? 'Physician' : 'Nurse', isDoctor),
                  ],
                ),
                if (staff.background.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    staff.background,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, height: 1.45, color: AppTheme.getInk(context)),
                  ),
                ],
                const SizedBox(height: 12),
                _buildScheduleBox(staff, limit: 3),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'View full profile',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary.withAlpha(220)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleBox(StaffSchedule staff, {int? limit}) {
    final entries = limit == null ? staff.schedule : staff.schedule.take(limit).toList();
    final hidden = staff.schedule.length - entries.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceSubtle(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getLine(context)),
      ),
      child: entries.isEmpty
          ? Text(
              'No upcoming clinic schedule.',
              style: TextStyle(fontSize: 12.5, color: AppTheme.getMuted(context)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 8),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entries[i].day,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                          ),
                        ),
                        Text(
                          '${entries[i].startTime} – ${entries[i].endTime}',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.getMuted(context)),
                        ),
                      ],
                    ),
                  ),
                if (hidden > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+$hidden more',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getMuted(context)),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showProfile(StaffSchedule staff) {
    final isDoctor = staff.role == StaffRole.doctor;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurface(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.getLine(context), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _buildAvatar(staff, radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.getInk(context)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(staff),
                        style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context)),
                      ),
                      const SizedBox(height: 6),
                      _buildRoleBadge(isDoctor ? 'Physician' : 'Nurse', isDoctor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Background',
              Text(
                staff.background.isEmpty ? 'This staff member has not added a background yet.' : staff.background,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: staff.background.isEmpty ? AppTheme.getMuted(context) : AppTheme.getInk(context),
                ),
              ),
            ),
            _buildSection(
              'Professional Credentials',
              Column(
                children: [
                  _buildInfoRow(Icons.badge_outlined, 'License', staff.licenseType.isEmpty ? 'Not provided' : staff.licenseType),
                  _buildInfoRow(
                    staff.isVerified ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
                    'Status',
                    staff.credentialStatus,
                    valueColor: staff.isVerified ? AppTheme.success : null,
                  ),
                  if (staff.otherCredentials.isNotEmpty)
                    _buildInfoRow(Icons.workspace_premium_outlined, 'Other', staff.otherCredentials),
                ],
              ),
            ),
            if (staff.email.isNotEmpty || staff.contactNumber.isNotEmpty)
              _buildSection(
                'Contact',
                Column(
                  children: [
                    if (staff.email.isNotEmpty) _buildInfoRow(Icons.email_outlined, 'Email', staff.email),
                    if (staff.contactNumber.isNotEmpty) _buildInfoRow(Icons.phone_outlined, 'Phone', staff.contactNumber),
                  ],
                ),
              ),
            _buildSection('Upcoming Clinic Schedule', _buildScheduleBox(staff)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppTheme.getMuted(context)),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(fontSize: 12.5, color: AppTheme.getMuted(context))),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppTheme.getInk(context)),
            ),
          ),
        ],
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
