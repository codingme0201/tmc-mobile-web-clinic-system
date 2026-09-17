import 'dart:convert';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../utils/api_client.dart';
import 'app_button.dart';

class HelpSupportTab extends StatelessWidget {
  const HelpSupportTab({super.key});

  void _openSupportModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String selectedCategory = 'General Inquiry';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Submit Support Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry')),
                        DropdownMenuItem(value: 'Appointment Concern', child: Text('Appointment Concern')),
                        DropdownMenuItem(value: 'Medical Records', child: Text('Medical Records')),
                        DropdownMenuItem(value: 'Prescription Concern', child: Text('Prescription Concern')),
                        DropdownMenuItem(value: 'Technical Issue', child: Text('Technical Issue')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Subject *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        hintText: 'Brief summary of your concern',
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a subject.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Message *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your question or issue in detail...',
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your message.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                setModalState(() => isSubmitting = true);
                                try {
                                  final apiClient = ApiClient();
                                  final res = await apiClient.post('/me/support', body: {
                                    'category': selectedCategory,
                                    'subject': subjectController.text.trim(),
                                    'message': messageController.text.trim(),
                                  });

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }

                                  if (context.mounted) {
                                    if (res.statusCode == 200 || res.statusCode == 201) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Support request submitted successfully.'),
                                          backgroundColor: AppTheme.success,
                                        ),
                                      );
                                    } else {
                                      final err = jsonDecode(res.body);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(err['message'] ?? 'Failed to submit concern.'),
                                          backgroundColor: AppTheme.danger,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: AppTheme.danger,
                                      ),
                                    );
                                  }
                                } finally {
                                  setModalState(() => isSubmitting = false);
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Send Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context),
        const SizedBox(height: 20),
        _buildSectionTitle('Frequently Asked Questions'),
        const SizedBox(height: 12),
        _buildFaqItem(
          question: 'How do I book an appointment?',
          answer: 'Tap on Appointments from the drawer menu or home screen and select your preferred date, time, and doctor.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'How do I view my medical records?',
          answer: 'Go to Medical Records from the bottom navigation bar to view your clinical history, diagnosed conditions, and recorded allergies.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'Can I reschedule my appointment?',
          answer: 'Yes, open your appointment details and tap the Reschedule button to select a new date and time.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'How do I request a Medical Certificate?',
          answer: 'Open the drawer menu, select Medical Certificates, and tap "Request Certificate" at the bottom right.',
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'How do I update my contact details?',
          answer: 'Tap the profile icon on the top right of the Home screen to view and update your contact number and emergency contact.',
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Need Further Assistance?'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.cardDecoration(borderRadius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Have a question or clinic concern?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
              ),
              const SizedBox(height: 4),
              const Text(
                'Send a direct inquiry or support message to clinic administrators.',
                style: TextStyle(fontSize: 13, color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Submit Support Request',
                icon: Icons.send_rounded,
                onPressed: () => _openSupportModal(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Clinic Contact Details'),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.phone_android_rounded,
          title: 'Mobile Hotline',
          subtitle: '+63 917 123 4567',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.phone_outlined,
          title: 'Telephone (Landline)',
          subtitle: '+63 (02) 8123-4567',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'clinic@tmccarelink.com',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.location_on_outlined,
          title: 'Clinic Location',
          subtitle: 'Health Sciences Building, Room 102, Main Campus',
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold, width: 2),
              color: Colors.white.withAlpha(35),
            ),
            child: const Icon(Icons.support_agent_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Browse clinic FAQs, contact medical staff, or submit a support inquiry',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.white.withAlpha(200)),
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

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(borderRadius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.help_outline_rounded, size: 14, color: AppTheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(fontSize: 12.5, color: AppTheme.muted, height: 1.4),
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
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(borderRadius: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
