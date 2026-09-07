import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/theme.dart';
import 'app/router.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'core/widgets/main_shell.dart';
import 'features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/clinic_information/presentation/controllers/clinic_information_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CareLinkApp());
}

class CareLinkApp extends StatefulWidget {
  const CareLinkApp({super.key});

  @override
  State<CareLinkApp> createState() => _CareLinkAppState();
}

class _CareLinkAppState extends State<CareLinkApp> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _authController.initialize();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authController),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => ClinicInformationController()),
      ],
      child: MaterialApp(
        title: 'TMC CareLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          return const AuthGuard(child: MainShell());
        }

        return const LoginScreen();
      },
    );
  }
}
