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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
            child: _submitted ? _buildSuccessState() : _buildFormState(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.success.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read, color: AppTheme.success, size: 36),
        ),
        const SizedBox(height: 20),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppTheme.muted),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.info.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Demo mode: No real email was sent. Check the demo credentials on the login screen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.muted),
          ),
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Back to Sign In',
          onPressed: () => Navigator.pop(context),
          icon: Icons.arrow_back,
        ),
      ],
    );
  }

  Widget _buildFormState() {
    return Form(
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
            'Reset Password',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppTheme.muted),
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            hintText: 'Enter your email',
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
          const SizedBox(height: 24),
          AppButton(
            label: 'Send Reset Link',
            onPressed: _handleSubmit,
            isLoading: _busy,
            icon: Icons.send,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }
}
