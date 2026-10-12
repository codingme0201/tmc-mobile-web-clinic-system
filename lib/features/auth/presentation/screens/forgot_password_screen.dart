import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _busy = false;
  bool _emailVerified = false;
  bool _passwordReset = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleVerifyEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    if (_busy) return;

    setState(() => _busy = true);

    final auth = context.read<AuthController>();
    final success = await auth.forgotPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _emailVerified = true);
    } else {
      _showError(auth.error ?? 'Failed to process request. Please try again.');
    }

    setState(() => _busy = false);
  }

  Future<void> _handleResetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_busy) return;

    setState(() => _busy = true);

    final auth = context.read<AuthController>();
    final success = await auth.resetPassword(
      email: _emailController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _passwordReset = true);
    } else {
      _showError(auth.error ?? 'Failed to reset password. Please try again.');
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final ink = AppTheme.getInk(context);
    final line = AppTheme.getLine(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: ink),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.getSurface(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: line),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, size: 18, color: ink),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _passwordReset
                ? _buildSuccessState()
                : _emailVerified
                    ? _buildNewPasswordState()
                    : _buildEmailState(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.success.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.success.withAlpha(60), width: 1.5),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'Password Updated',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The password for\n${_emailController.text.trim()}\nhas been reset. You can now sign in with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: muted, height: 1.4),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Back to Sign In',
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailState() {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 22),
      child: Form(
        key: _emailFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withAlpha(50), width: 1.5),
              ),
              child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the email address registered to your student account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Email Address',
              controller: _emailController,
              hintText: 'name@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onEditingComplete: _handleVerifyEmail,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required.';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            AppButton(
              label: 'Continue',
              onPressed: _handleVerifyEmail,
              isLoading: _busy,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              child: const Text('Return to Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPasswordState() {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 22),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withAlpha(50), width: 1.5),
              ),
              child: const Icon(Icons.password_rounded, color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Set New Password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new password for\n${_emailController.text.trim()}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: muted, height: 1.4),
            ),
            const SizedBox(height: 24),
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
                if (v.length < 8) return 'Password must be at least 8 characters.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
              hintText: 'Confirm new password',
              prefixIcon: Icons.verified_user_outlined,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onEditingComplete: _handleResetPassword,
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
            const SizedBox(height: 22),
            AppButton(
              label: 'Reset Password',
              onPressed: _handleResetPassword,
              isLoading: _busy,
              icon: Icons.lock_reset_rounded,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() {
                _emailVerified = false;
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              }),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              child: const Text('Use a different email'),
            ),
          ],
        ),
      ),
    );
  }
}
