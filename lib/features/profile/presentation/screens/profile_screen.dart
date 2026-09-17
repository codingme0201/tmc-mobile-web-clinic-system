import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../../domain/models/profile.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.session?.user.id ?? '';
      context.read<ProfileController>().loadProfile(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/account-security'),
          ),
        ],
      ),
      body: Consumer<ProfileController>(
        builder: (context, profileCtrl, _) {
          switch (profileCtrl.status) {
            case ProfileStatus.initial:
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            case ProfileStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                    const SizedBox(height: 16),
                    Text(
                      profileCtrl.error ?? 'Unable to load profile.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        final auth = context.read<AuthController>();
                        profileCtrl.loadProfile(auth.session?.user.id ?? '');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            case ProfileStatus.loaded:
            case ProfileStatus.updating:
              final profile = profileCtrl.profile;
              if (profile == null) {
                return const Center(
                  child: Text('No profile data available.', style: TextStyle(color: AppTheme.muted)),
                );
              }
              return _buildProfile(context, profile, profileCtrl.status == ProfileStatus.updating);
          }
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, Profile profile, bool isUpdating) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow(Icons.person_outline, 'Full Name', profile.name),
              const Divider(height: 1),
              _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
              const Divider(height: 1),
              _buildInfoRow(Icons.phone_android_rounded, 'Mobile Number', profile.phone ?? 'Not provided'),
              const Divider(height: 1),
              _buildInfoRow(Icons.phone_outlined, 'Telephone', profile.telephone ?? 'Not provided'),
              const Divider(height: 1),
              _buildInfoRow(Icons.home_outlined, 'Address', profile.address ?? 'Not provided'),
              const Divider(height: 1),
              _buildInfoRow(
                Icons.cake_outlined,
                'Date of Birth',
                '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
              ),
              const Divider(height: 1),
              _buildInfoRow(Icons.wc_outlined, 'Gender', profile.gender ?? 'Not specified'),
            ]),
            const SizedBox(height: 16),
            _buildEditButton(context, profile),
            const SizedBox(height: 24),
            _buildSectionTitle('Student Information'),
            const SizedBox(height: 12),
            profile.studentInfo != null
                ? _buildStudentInfo(profile.studentInfo!)
                : _buildEmptyCard('Student information is not available.'),
            const SizedBox(height: 24),
            _buildSectionTitle('Patient Medical Information'),
            const SizedBox(height: 12),
            profile.medicalInfo != null
                ? _buildMedicalInfo(profile.medicalInfo!)
                : _buildEmptyCard('No medical information is currently available.'),
            const SizedBox(height: 24),
            _buildSectionTitle('Account Status'),
            const SizedBox(height: 12),
            _buildAccountStatus(profile.accountStatus),
            const SizedBox(height: 24),
            _buildSectionTitle('Security'),
            const SizedBox(height: 12),
            _buildSecurityTile(context),
            const SizedBox(height: 32),
          ],
        ),
        if (isUpdating)
          Container(
            color: Colors.black.withAlpha(25),
            child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          ),
      ],
    );
  }

  Widget _buildProfileHeader(Profile profile) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold, width: 2),
              color: Colors.white.withAlpha(35),
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(210),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(profile.accountStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AccountStatus status) {
    Color color;
    String label;

    switch (status) {
      case AccountStatus.active:
        color = AppTheme.success;
        label = 'Active Account';
      case AccountStatus.inactive:
        color = AppTheme.muted;
        label = 'Inactive';
      case AccountStatus.pending:
        color = AppTheme.warning;
        label = 'Pending Verification';
      case AccountStatus.suspended:
        color = AppTheme.danger;
        label = 'Suspended';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(120)),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecoration(borderRadius: 16),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.muted),
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

  Widget _buildEditButton(BuildContext context, Profile profile) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final updated = await Navigator.push<Profile>(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(profile: profile),
            ),
          );
          if (updated != null && mounted) {
            if (!context.mounted) return;
            context.read<ProfileController>().updateProfile(updated);
          }
        },
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Edit Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildStudentInfo(StudentInfo info) {
    return _buildInfoCard([
      _buildInfoRow(Icons.badge_outlined, 'Student ID', info.studentId),
      const Divider(height: 1),
      _buildInfoRow(Icons.school_outlined, 'Program', info.program),
      const Divider(height: 1),
      _buildInfoRow(Icons.calendar_today, 'Year Level', info.yearLevel),
      const Divider(height: 1),
      _buildInfoRow(Icons.grid_view_rounded, 'Block', info.block),
      const Divider(height: 1),
      _buildInfoRow(Icons.how_to_reg, 'Status', info.enrollmentStatus),
    ]);
  }

  Widget _buildMedicalInfo(MedicalInfo info) {
    return _buildInfoCard([
      _buildInfoRow(Icons.bloodtype_outlined, 'Blood Type', info.bloodType),
      if (info.allergies != null) ...[
        const Divider(height: 1),
        _buildInfoRow(Icons.warning_amber_outlined, 'Allergies', info.allergies!),
      ],
      if (info.conditions != null) ...[
        const Divider(height: 1),
        _buildInfoRow(Icons.medical_services_outlined, 'Conditions', info.conditions!),
      ],
      if (info.medications != null) ...[
        const Divider(height: 1),
        _buildInfoRow(Icons.medication_outlined, 'Medications', info.medications!),
      ],
      if (info.emergencyContact != null) ...[
        const Divider(height: 1),
        _buildInfoRow(Icons.contact_phone_outlined, 'Emergency Contact', info.emergencyContact!),
      ],
      if (info.emergencyContactNumber != null) ...[
        const Divider(height: 1),
        _buildInfoRow(Icons.phone_android_rounded, 'Emergency Mobile', info.emergencyContactNumber!),
      ],
    ]);
  }

  Widget _buildAccountStatus(AccountStatus status) {
    String label;
    Color color;
    IconData icon;

    switch (status) {
      case AccountStatus.active:
        label = 'Your account is active and in good standing.';
        color = AppTheme.success;
        icon = Icons.check_circle_outline;
      case AccountStatus.inactive:
        label = 'Your account is currently inactive.';
        color = AppTheme.muted;
        icon = Icons.pause_circle_outline;
      case AccountStatus.pending:
        label = 'Your account is pending verification.';
        color = AppTheme.warning;
        icon = Icons.hourglass_empty;
      case AccountStatus.suspended:
        label = 'Your account has been suspended. Please contact support.';
        color = AppTheme.danger;
        icon = Icons.block;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.name[0].toUpperCase() + status.name.substring(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/account-security'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line),
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppTheme.primary, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account & Security',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage password and security settings',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.mutedLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}
