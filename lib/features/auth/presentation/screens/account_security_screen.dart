import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../controllers/auth_controller.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Security'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
              _buildSectionTitle('Account Information'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(Icons.person_outline, 'Name', user?.name ?? 'N/A'),
                const Divider(height: 1),
                _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? 'N/A'),
                const Divider(height: 1),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Member Since',
                  user?.createdAt != null
                      ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                      : 'N/A',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Security'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildActionRow(
                  context,
                  icon: Icons.lock_reset,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                const Divider(height: 1),
                _buildInfoRow(
                  Icons.shield_outlined,
                  'Session',
                  'Active since ${session?.loginTime != null ? _formatTime(session!.loginTime) : 'N/A'}',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Danger Zone'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildActionRow(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account on this device',
                  titleColor: AppTheme.danger,
                  iconColor: AppTheme.danger,
                  onTap: () => _showLogoutDialog(context, auth),
                ),
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Demo Mode: Account security features are simulated. Real security will be managed by the backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ),
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
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withAlpha(51),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.muted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
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

  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? AppTheme.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
            Icon(Icons.chevron_right, size: 20, color: iconColor ?? AppTheme.muted),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
