import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../app/theme_controller.dart';
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
            _buildProfileHeader(context, profile),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Appearance & Theme'),
            const SizedBox(height: 12),
            _buildThemeSelector(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Personal Information'),
            const SizedBox(height: 12),
            _buildInfoCard(context, [
              _buildInfoRow(context, Icons.person_outline, 'Full Name', profile.name),
              Divider(height: 1, color: AppTheme.getLine(context)),
              _buildInfoRow(context, Icons.email_outlined, 'Email', profile.email),
              Divider(height: 1, color: AppTheme.getLine(context)),
              _buildInfoRow(context, Icons.phone_android_rounded, 'Mobile Number', profile.phone ?? 'Not provided'),
              Divider(height: 1, color: AppTheme.getLine(context)),
              _buildInfoRow(context, Icons.phone_outlined, 'Telephone', profile.telephone ?? 'Not provided'),
              Divider(height: 1, color: AppTheme.getLine(context)),
              _buildInfoRow(context, Icons.home_outlined, 'Address', profile.address ?? 'Not provided'),
              Divider(height: 1, color: AppTheme.getLine(context)),
              _buildInfoRow(
                context,
                Icons.cake_outlined,
                'Date of Birth',
                '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
              ),
              Divider(height: 1, color: AppTheme.getLine(context)),
              _buildInfoRow(context, Icons.wc_outlined, 'Gender', profile.gender ?? 'Not specified'),
            ]),
            const SizedBox(height: 16),
            _buildEditButton(context, profile),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Student Information'),
            const SizedBox(height: 12),
            profile.studentInfo != null
                ? _buildStudentInfo(context, profile.studentInfo!)
                : _buildEmptyCard(context, 'Student information is not available.'),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Patient Medical Information'),
            const SizedBox(height: 12),
            profile.medicalInfo != null
                ? _buildMedicalInfo(context, profile.medicalInfo!)
                : _buildEmptyCard(context, 'No medical information is currently available.'),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Account Status'),
            const SizedBox(height: 12),
            _buildAccountStatus(context, profile.accountStatus),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Security'),
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

  Widget _buildProfileHeader(BuildContext context, Profile profile) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.heroGradientDark : AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.primaryLight.withAlpha(50) : Colors.white.withAlpha(40),
          width: 1,
        ),
        boxShadow: isDark ? AppTheme.cardShadowDark : AppTheme.primaryGlow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold, width: 2),
              color: isDark ? AppTheme.darkSurface : Colors.white.withAlpha(35),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withAlpha(45),
                  blurRadius: 10,
                ),
              ],
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

  Widget _buildThemeSelector(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final currentMode = themeController.themeMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palette & Ambience',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.getInk(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred visual theme for TMC CareLink',
            style: TextStyle(
              fontSize: 11.5,
              color: AppTheme.getMuted(context),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildThemeOption(
                context,
                title: 'Light',
                icon: Icons.light_mode_rounded,
                selected: currentMode == ThemeMode.light,
                onTap: () => themeController.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context,
                title: 'Dark',
                icon: Icons.dark_mode_rounded,
                selected: currentMode == ThemeMode.dark,
                onTap: () => themeController.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context,
                title: 'System',
                icon: Icons.brightness_auto_rounded,
                selected: currentMode == ThemeMode.system,
                onTap: () => themeController.setThemeMode(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = AppTheme.isDark(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppTheme.primary.withAlpha(45) : AppTheme.primaryLight)
                : AppTheme.getSurfaceSubtle(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.getLine(context),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(selected ? 35 : 0),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppTheme.primary : AppTheme.getMuted(context),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppTheme.primary : AppTheme.getInk(context),
                ),
              ),
            ],
          ),
        ),
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
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
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
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.getInk(context),
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.getMuted(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppTheme.getMuted(context)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getInk(context),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildStudentInfo(BuildContext context, StudentInfo info) {
    return _buildInfoCard(context, [
      _buildInfoRow(context, Icons.badge_outlined, 'Student ID', info.studentId),
      Divider(height: 1, color: AppTheme.getLine(context)),
      _buildInfoRow(context, Icons.school_outlined, 'Program', info.program),
      Divider(height: 1, color: AppTheme.getLine(context)),
      _buildInfoRow(context, Icons.calendar_today, 'Year Level', info.yearLevel),
      Divider(height: 1, color: AppTheme.getLine(context)),
      _buildInfoRow(context, Icons.grid_view_rounded, 'Block', info.block),
      Divider(height: 1, color: AppTheme.getLine(context)),
      _buildInfoRow(context, Icons.how_to_reg, 'Status', info.enrollmentStatus),
    ]);
  }

  Widget _buildMedicalInfo(BuildContext context, MedicalInfo info) {
    return _buildInfoCard(context, [
      _buildInfoRow(context, Icons.bloodtype_outlined, 'Blood Type', info.bloodType),
      if (info.allergies != null) ...[
        Divider(height: 1, color: AppTheme.getLine(context)),
        _buildInfoRow(context, Icons.warning_amber_outlined, 'Allergies', info.allergies!),
      ],
      if (info.conditions != null) ...[
        Divider(height: 1, color: AppTheme.getLine(context)),
        _buildInfoRow(context, Icons.medical_services_outlined, 'Conditions', info.conditions!),
      ],
      if (info.medications != null) ...[
        Divider(height: 1, color: AppTheme.getLine(context)),
        _buildInfoRow(context, Icons.medication_outlined, 'Medications', info.medications!),
      ],
      if (info.emergencyContact != null) ...[
        Divider(height: 1, color: AppTheme.getLine(context)),
        _buildInfoRow(context, Icons.contact_phone_outlined, 'Emergency Contact', info.emergencyContact!),
      ],
      if (info.emergencyContactNumber != null) ...[
        Divider(height: 1, color: AppTheme.getLine(context)),
        _buildInfoRow(context, Icons.phone_android_rounded, 'Emergency Mobile', info.emergencyContactNumber!),
      ],
    ]);
  }

  Widget _buildAccountStatus(BuildContext context, AccountStatus status) {
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
        color = AppTheme.getMuted(context);
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
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
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
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context)),
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
        decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account & Security',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getInk(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage password and security settings',
                    style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.getMuted(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.getMutedLight(context), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context)),
            ),
          ),
        ],
      ),
    );
  }
}
