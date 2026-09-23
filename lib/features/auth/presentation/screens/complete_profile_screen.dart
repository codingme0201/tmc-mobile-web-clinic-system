import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _blockController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final ApiClient _apiClient = ApiClient();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();
    _blockController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final res = await _apiClient.get('/me/profile');
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body)['data'] ?? {};
        setState(() {
          _firstNameController.text = (data['firstName'] ?? '').toString();
          _middleNameController.text = (data['middleName'] ?? '').toString();
          _lastNameController.text = (data['lastName'] ?? '').toString();
          if (data['age'] != null) {
            _ageController.text = data['age'].toString();
          }
          _studentIdController.text = (data['studentId'] ?? data['patientId'] ?? '').toString();
          _courseController.text = (data['course'] ?? data['courseDept'] ?? '').toString();
          _blockController.text = (data['block'] ?? '').toString();
          _addressController.text = (data['address'] ?? 'Tagum Norte, Trinidad, Bohol, Philippines').toString();
          _nationalityController.text = (data['nationality'] ?? 'Filipino').toString();
          _phoneController.text = (data['phone'] ?? data['contact'] ?? '').toString();
          _emergencyNameController.text = (data['emergencyContactName'] ?? '').toString();
          _emergencyPhoneController.text = (data['emergencyContactPhone'] ?? '').toString();

          // Fallback name splitting if name exists but first/last are blank
          if (_firstNameController.text.isEmpty && data['name'] != null) {
            final parts = data['name'].toString().trim().split(' ');
            if (parts.length == 1) {
              _firstNameController.text = parts[0];
            } else if (parts.length >= 2) {
              _firstNameController.text = parts.sublist(0, parts.length - 1).join(' ');
              _lastNameController.text = parts.last;
            }
          }
        });
      }
    } catch (_) {
      // Fallback defaults
      if (mounted) {
        setState(() {
          _addressController.text = 'Tagum Norte, Trinidad, Bohol, Philippines';
          _nationalityController.text = 'Filipino';
          _blockController.text = 'Block 1';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final payload = {
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'studentId': _studentIdController.text.trim(),
        'course': _courseController.text.trim(),
        'block': _blockController.text.trim(),
        'address': _addressController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'emergencyContactName': _emergencyNameController.text.trim(),
        'emergencyContactPhone': _emergencyPhoneController.text.trim(),
      };

      final res = await _apiClient.put('/me/profile', body: payload);

      if (!mounted) return;

      if (res.statusCode == 200) {
        context.read<AuthController>().markProfileComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile completed successfully! Welcome to CareLink.'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else {
        final body = jsonDecode(res.body);
        String msg = body['message'] ?? 'Failed to update profile. Please verify all fields.';
        if (body['errors'] is Map) {
          final first = (body['errors'] as Map).values.first;
          if (first is List && first.isNotEmpty) {
            msg = first.first.toString();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthController>();
    await auth.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackground(context),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      appBar: AppBar(
        title: Text(
          'Student Profile Setup',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: ink),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _handleLogout,
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.danger),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Your Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Please complete your student medical profile before proceeding to the clinic portal.',
                              style: TextStyle(fontSize: 12.5, color: muted, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION 1: Personal Details
                _buildSectionHeader('1. Personal Identity', Icons.person_rounded),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'First Name *',
                        hintText: 'e.g. Juan',
                        controller: _firstNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Middle Name',
                        hintText: 'e.g. Santos (Optional)',
                        controller: _middleNameController,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Last Name *',
                        hintText: 'e.g. Dela Cruz',
                        controller: _lastNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Last name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Age *',
                              hintText: 'e.g. 20',
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Age is required';
                                final age = int.tryParse(v.trim());
                                if (age == null || age <= 0 || age > 120) return 'Valid age required';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Nationality *',
                              hintText: 'e.g. Filipino',
                              controller: _nationalityController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nationality is required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION 2: Academic Details
                _buildSectionHeader('2. Academic Information', Icons.school_rounded),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Student ID *',
                        hintText: 'e.g. 24-021128',
                        controller: _studentIdController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Student ID is required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Course / Program *',
                        hintText: 'e.g. BS Information Technology',
                        controller: _courseController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Course is required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Block No. *',
                        hintText: 'e.g. Block 1',
                        controller: _blockController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Block number is required' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION 3: Contact & Address
                _buildSectionHeader('3. Contact & Residence', Icons.home_rounded),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Phone Number *',
                        hintText: 'e.g. 09123456789',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Home Address *',
                        hintText: 'Tagum Norte, Trinidad, Bohol, Philippines',
                        controller: _addressController,
                        maxLines: 2,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION 4: Emergency Contact
                _buildSectionHeader('4. Emergency Contact', Icons.contact_emergency_rounded),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(context: context, borderRadius: 16),
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Guardian / Contact Person *',
                        hintText: 'e.g. Maria Dela Cruz (Mother)',
                        controller: _emergencyNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Guardian name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Guardian Contact No. *',
                        hintText: 'e.g. 09987654321',
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Guardian contact number is required' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  label: 'Complete Profile & Continue',
                  icon: Icons.check_circle_rounded,
                  isLoading: _saving,
                  onPressed: _handleSave,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
