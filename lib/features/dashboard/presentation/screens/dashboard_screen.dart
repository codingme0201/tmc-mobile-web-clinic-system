import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMC CareLink'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          final user = auth.session?.user;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildWelcomeHeader(user?.name ?? 'User'),
              const SizedBox(height: 24),
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Upcoming'),
              const SizedBox(height: 12),
              _buildUpcomingCard(),
              const SizedBox(height: 24),
              _buildAccountSecurityTile(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withAlpha(51),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 22,
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
                  'Welcome, $name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TMC CareLink Patient Portal',
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(Icons.calendar_today, 'Appointments', () {}),
      _QuickAction(Icons.medical_information, 'Medical Records', () {}),
      _QuickAction(Icons.description, 'Prescriptions', () {}),
      _QuickAction(Icons.notifications, 'Notifications', () {}),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildActionCard(a),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line),
        ),
        child: Column(
          children: [
            Icon(action.icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.ink),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_available, color: AppTheme.mutedLight, size: 40),
          SizedBox(height: 12),
          Text(
            'No upcoming appointments',
            style: TextStyle(fontSize: 14, color: AppTheme.muted),
          ),
          SizedBox(height: 4),
          Text(
            'Book an appointment to get started.',
            style: TextStyle(fontSize: 12, color: AppTheme.mutedLight),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSecurityTile(BuildContext context) {
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
                    'Manage password, session, and security settings',
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
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(this.icon, this.label, this.onTap);
}
