import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/account_security_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String changePassword = '/change-password';
  static const String accountSecurity = '/account-security';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: DashboardScreen()));
      case changePassword:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: ChangePasswordScreen()));
      case accountSecurity:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: AccountSecurityScreen()));
      case profile:
        return MaterialPageRoute(builder: (_) => const AuthGuard(child: AccountSecurityScreen()));
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pushReplacementNamed(context, AppRouter.login);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return child;
      },
    );
  }
}
