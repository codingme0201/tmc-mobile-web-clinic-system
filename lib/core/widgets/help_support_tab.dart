import 'package:flutter/material.dart';
import '../../app/theme.dart';

class HelpSupportTab extends StatelessWidget {
  const HelpSupportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSectionTitle('Frequently Asked Questions'),
        const SizedBox(height: 12),
        _buildFaqItem(
          question: 'How do I book an appointment?',
          answer: 'Tap on Appointments from the drawer menu and use the booking form to select your preferred date and doctor.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'How do I view my medical records?',
          answer: 'Go to Medical Records from the bottom navigation bar to view all your past consultations and lab results.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'Can I reschedule my appointment?',
          answer: 'Yes, open your appointment details and tap the reschedule button to select a new date and time.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'How do I update my profile?',
          answer: 'Tap the profile icon in the top-right corner of the home screen to view and edit your profile information.',
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Contact Us'),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.phone_outlined,
          title: 'Phone',
          subtitle: '(02) 8123-4567',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'support@tmccarelink.com',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.location_on_outlined,
          title: 'Address',
          subtitle: 'TMC Building, Quezon City',
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.help_outline, size: 40, color: AppTheme.primary),
          SizedBox(height: 12),
          Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Browse FAQs or contact our support team',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.ink,
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
