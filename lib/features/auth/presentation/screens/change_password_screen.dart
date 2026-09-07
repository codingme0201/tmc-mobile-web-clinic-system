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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to change password. Please try again.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset, color: AppTheme.primary, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update your password to keep your account secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'Current Password',
                    controller: _currentPasswordController,
                    hintText: 'Enter current password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'New Password',
                    controller: _newPasswordController,
                    hintText: 'Enter new password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Confirm New Password',
                    controller: _confirmPasswordController,
                    hintText: 'Confirm new password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _handleChangePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Update Password',
                    onPressed: _handleChangePassword,
                    isLoading: _busy,
                    icon: Icons.check_circle_outline,
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
