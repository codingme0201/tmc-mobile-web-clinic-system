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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _busy = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_busy) return;

    setState(() => _busy = true);

    final auth = context.read<AuthController>();
    final success = await auth.forgotPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to process request. Please try again.'),
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
            child: _submitted ? _buildSuccessState() : _buildFormState(),
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
            child: const Icon(Icons.mark_email_read_rounded, color: AppTheme.success, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'Check Your Email',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve dispatched password reset instructions to\n${_emailController.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withAlpha(16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.info.withAlpha(40)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.info),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If an account matches this email, you will receive password reset instructions.',
                    style: TextStyle(fontSize: 12, color: ink, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
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

  Widget _buildFormState() {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 22),
      child: Form(
        key: _formKey,
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
              'Enter your registered email address and we\'ll dispatch secure instructions to reset your password.',
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
              onEditingComplete: _handleSubmit,
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
              label: 'Send Reset Link',
              onPressed: _handleSubmit,
              isLoading: _busy,
              icon: Icons.send_rounded,
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
}
