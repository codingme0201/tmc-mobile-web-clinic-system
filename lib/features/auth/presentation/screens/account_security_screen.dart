import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../controllers/auth_controller.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

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
              'SECURITY CENTER',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Account & Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          final session = auth.session;
          final user = session?.user;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildProfileHeader(user?.name ?? 'User', user?.email ?? ''),
              const SizedBox(height: 24),
              _buildSectionHeader('IDENTITY DETAILS', 'Account Information'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(Icons.person_outline_rounded, 'Full Name', user?.name ?? 'N/A'),
                const Divider(height: 1, color: AppTheme.line),
                _buildInfoRow(Icons.email_outlined, 'Email Address', user?.email ?? 'N/A'),
                const Divider(height: 1, color: AppTheme.line),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  'Member Since',
                  user?.createdAt != null
                      ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                      : 'N/A',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('CREDENTIALS', 'Access & Authentication'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildActionRow(
                  context,
                  icon: Icons.lock_reset_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your account password and security key',
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                const Divider(height: 1, color: AppTheme.line),
                _buildInfoRow(
                  Icons.shield_outlined,
                  'Session Status',
                  'Active (${session?.loginTime != null ? _formatTime(session!.loginTime) : 'N/A'})',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('SESSION TERMINATION', 'Sign Out & Device Exit'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.danger.withAlpha(40)),
                  boxShadow: AppTheme.cardShadowSubtle,
                ),
                child: _buildActionRow(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'Safely terminate your active session on this device',
                  titleColor: AppTheme.danger,
                  iconColor: AppTheme.danger,
                  onTap: () => _showLogoutDialog(context, auth),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withAlpha(25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 20, color: AppTheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your medical records and session tokens are protected under standard clinical encryption protocols.',
                        style: TextStyle(fontSize: 12, color: AppTheme.inkLight, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour > 12 ? time.hour - 12 : time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${h == 0 ? 12 : h}:$m $period';
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withAlpha(40),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, size: 16, color: AppTheme.goldLight),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(210),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String kicker, String title) {
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: AppTheme.muted, fontWeight: FontWeight.w500),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final effectiveIconColor = iconColor ?? AppTheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: effectiveIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.mutedLight),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.danger, size: 22),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you wish to terminate this session? You will need to log back in to access your records.',
          style: TextStyle(fontSize: 14, color: AppTheme.muted, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

