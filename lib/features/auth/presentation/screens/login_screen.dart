import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../app/theme_controller.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/api_client.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_busy) return;

    setState(() => _busy = true);

    final auth = context.read<AuthController>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      final errorMessage = auth.error ?? 'Login failed. Please try again.';
      if (errorMessage.contains('web clinic portal') || errorMessage.contains('patient users only')) {
        _showAccessRestrictionDialog(errorMessage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    setState(() => _busy = false);
  }

  void _showAccessRestrictionDialog(String message) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppTheme.getLine(context)),
        ),
        backgroundColor: AppTheme.getSurface(context),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_person_rounded, color: AppTheme.danger, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Access Restricted',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.getInk(context),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.danger.withAlpha(isDark ? 30 : 18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.danger.withAlpha(50)),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppTheme.getInk(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Clinic personnel (Administrators, Doctors, and Nurses) must sign in using the TMC CareLink web portal.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getMuted(context),
                height: 1.35,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Understood',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showServerSettingsDialog() async {
    final currentUrl = await ApiClient().getBaseUrl();
    final urlController = TextEditingController(text: currentUrl);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final line = AppTheme.getLine(ctx);
        final ink = AppTheme.getInk(ctx);
        final muted = AppTheme.getMuted(ctx);
        final surface = AppTheme.getSurface(ctx);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: line),
          ),
          backgroundColor: surface,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dns_rounded, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Server Network Setup',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect to your computer running the Laravel backend on the same local Wi-Fi network.',
                  style: TextStyle(fontSize: 13, color: muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  style: TextStyle(fontSize: 13.5, color: ink),
                  decoration: InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'http://192.168.8.56:8000/api',
                    prefixIcon: const Icon(Icons.link_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'QUICK PRESETS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('Wi-Fi PC (192.168.8.56)', style: TextStyle(fontSize: 11)),
                      onPressed: () => urlController.text = 'http://192.168.8.56:8000/api',
                    ),
                    ActionChip(
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () => urlController.text = 'http://10.0.2.2:8000/api',
                    ),
                    ActionChip(
                      label: const Text('Localhost (127.0.0.1)', style: TextStyle(fontSize: 11)),
                      onPressed: () => urlController.text = 'http://127.0.0.1:8000/api',
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  await ApiClient.saveBaseUrl(newUrl);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Server URL set to: $newUrl'),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save & Connect', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final themeController = context.watch<ThemeController>();
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glow in top corners
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? AppTheme.primaryLight : AppTheme.primary).withAlpha(16),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold.withAlpha(isDark ? 10 : 8),
                ),
              ),
            ),

            // Top Quick Controls (Server setup & Theme Switcher)
            Positioned(
              top: 12,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: isDark ? AppTheme.darkSurfaceSubtle : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.getLine(context)),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.dns_rounded,
                          color: AppTheme.getInk(context),
                          size: 19,
                        ),
                        tooltip: 'Server Connection Settings',
                        onPressed: _showServerSettingsDialog,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: isDark ? AppTheme.darkSurfaceSubtle : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.getLine(context)),
                      ),
                      child: IconButton(
                        icon: Icon(
                          themeController.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: themeController.isDarkMode ? AppTheme.gold : AppTheme.primary,
                          size: 20,
                        ),
                        tooltip: themeController.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        onPressed: () => themeController.toggleTheme(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      // Brand Emblem
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          gradient: isDark ? AppTheme.heroGradientDark : AppTheme.heroGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(isDark ? 80 : 70),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.gold.withAlpha(120),
                            width: 1.6,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'TMC CareLink',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: ink,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(isDark ? 35 : 18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary.withAlpha(isDark ? 60 : 35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_rounded, size: 12, color: AppTheme.primaryLight),
                            SizedBox(width: 6),
                            Text(
                              'PATIENT PORTAL',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Executive Card Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.cardDecoration(
                          context: context,
                          borderRadius: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Access your health records and appointments',
                              style: TextStyle(
                                fontSize: 13,
                                color: muted,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 22),
                            AppTextField(
                              label: 'Email Address',
                              controller: _emailController,
                              hintText: 'student@tmc.edu.ph',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required.';
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              label: 'Password',
                              controller: _passwordController,
                              hintText: 'Enter your account password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: _handleLogin,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: muted,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                ),
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppButton(
                              label: 'Sign In to Portal',
                              onPressed: _handleLogin,
                              isLoading: _busy,
                              icon: Icons.login_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Register Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account yet? ",
                            style: TextStyle(color: muted, fontSize: 13.5),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Register Now',
                              style: TextStyle(
                                color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
