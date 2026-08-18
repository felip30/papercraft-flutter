import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_identifierCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Completa usuario/email y contraseña');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await context.read<AuthService>().login(
          _identifierCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteFondo),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => AppColors.gradienteCyanMagenta.createShader(b),
                      child: const Text(
                        'PAPERCRAFT SYSTEMS',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Diseña • Construye • Domina',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textoGris),
                    ),
                    const SizedBox(height: 40),
                    const Text('Iniciar Sesión',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.cyan)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _identifierCtrl,
                      style: const TextStyle(color: AppColors.textoClaro),
                      decoration: const InputDecoration(labelText: 'Usuario o Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textoClaro),
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.magenta)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Ingresar'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('¿No tienes cuenta? Regístrate',
                          style: TextStyle(color: AppColors.textoGris)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
