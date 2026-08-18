import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _securityQuestion = TextEditingController();
  final _securityAnswer = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_password.text != _passwordConfirm.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await context.read<AuthService>().register(
          username: _username.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          securityQuestion: _securityQuestion.text.trim(),
          securityAnswer: _securityAnswer.text.trim(),
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    } else if (error == 'CONFIRM_EMAIL') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Revisa tu correo para confirmarla.')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteFondo),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(_username, 'Nombre de usuario'),
                  const SizedBox(height: 14),
                  _field(_email, 'Email'),
                  const SizedBox(height: 14),
                  _field(_password, 'Contraseña', obscure: true),
                  const SizedBox(height: 14),
                  _field(_passwordConfirm, 'Confirmar contraseña', obscure: true),
                  const SizedBox(height: 14),
                  _field(_securityQuestion, 'Pregunta de seguridad (ej: ¿tu color favorito?)'),
                  const SizedBox(height: 14),
                  _field(_securityAnswer, 'Respuesta de seguridad'),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.magenta)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Crear Cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textoClaro),
      decoration: InputDecoration(labelText: label),
    );
  }
}
