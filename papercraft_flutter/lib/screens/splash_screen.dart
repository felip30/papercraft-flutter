import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.loading) {
          return Scaffold(
            backgroundColor: AppColors.fondoOscuro,
            body: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => AppColors.gradienteCyanMagenta.createShader(bounds),
                child: const Text(
                  'PAPERCRAFT SYSTEMS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          );
        }
        return auth.isAuthenticated ? const MainShell() : const LoginScreen();
      },
    );
  }
}
