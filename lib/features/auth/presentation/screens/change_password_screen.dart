import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _busy = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_busy) return;

    setState(() => _busy = true);

    final auth = context.read<AuthController>();
    final success = await auth.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to change password. Please try again.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    setState(() => _busy = false);
  }

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
              'SECURITY CREDENTIALS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldLight,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Colors.white, Color(0xFFF0F5F3)],
                        radius: 0.85,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.gold, width: 2),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 34),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Update Access Key',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ensure your account remains safe with a strong clinical credential.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: AppTheme.muted, height: 1.4),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration(radius: 20),
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Current Password',
                          controller: _currentPasswordController,
                          hintText: 'Enter current password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureCurrent,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.muted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Current password is required.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'New Password',
                          controller: _newPasswordController,
                          hintText: 'Enter new password',
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: _obscureNew,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.muted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'New password is required.';
                            if (v.length < 6) return 'Password must be at least 6 characters.';
                            if (v == _currentPasswordController.text) {
                              return 'New password must be different from current password.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'Confirm New Password',
                          controller: _confirmPasswordController,
                          hintText: 'Confirm new password',
                          prefixIcon: Icons.verified_user_outlined,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _handleChangePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.muted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm your new password.';
                            if (v != _newPasswordController.text) return 'Passwords do not match.';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Update Password',
                    onPressed: _handleChangePassword,
                    isLoading: _busy,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

