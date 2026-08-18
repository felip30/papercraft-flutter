import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

/// Equivalente a js/auth.js — mismo backend, mismas reglas de seguridad
/// (RLS ya las hace cumplir Supabase, sin importar desde qué app se
/// conecte). Cubre login, registro y el estado de la cuenta (perfil,
/// rol, veto por faltas). El resto de auth.js (sesión única entre
/// dispositivos, subida de foto, recuperación de contraseña) queda
/// pendiente para una siguiente pasada.
class AuthService extends ChangeNotifier {
  Map<String, dynamic>? profile;
  bool isAuthenticated = false;
  bool loading = true;

  bool get isAdmin => profile?['role'] == 'admin';
  String get username => profile?['username'] ?? '';
  String get email => profile?['email'] ?? '';
  int get credits => (profile?['credits'] as num?)?.toInt() ?? 0;

  Future<void> init() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await _loadProfile(session.user.id);
    }
    loading = false;
    notifyListeners();

    supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedOut) {
        isAuthenticated = false;
        profile = null;
        notifyListeners();
      }
    });
  }

  Future<bool> _loadProfile(String userId) async {
    try {
      final data = await supabase.from('usuarios').select().eq('id', userId).single();
      profile = data;
      isAuthenticated = true;
      return true;
    } catch (e) {
      debugPrint('Error al cargar el perfil: $e');
      isAuthenticated = false;
      return false;
    }
  }

  /// Acepta username o email, igual que en la web — si no tiene "@",
  /// se busca primero el email real detrás de ese username.
  Future<String?> login(String identifier, String password) async {
    try {
      String emailToUse = identifier;
      if (!identifier.contains('@')) {
        final resolved = await supabase.rpc('get_email_by_username', params: {'p_username': identifier});
        if (resolved == null) return 'Usuario no encontrado';
        emailToUse = resolved as String;
      }

      final res = await supabase.auth.signInWithPassword(email: emailToUse, password: password);
      if (res.user == null) return 'No se pudo iniciar sesión';

      final loaded = await _loadProfile(res.user!.id);
      if (!loaded) return 'No se pudo cargar el perfil de la cuenta';

      notifyListeners();
      return null; // sin error = éxito
    } on AuthException catch (e) {
      return e.message.contains('Invalid login credentials')
          ? 'Usuario o contraseña incorrectos'
          : e.message;
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    if (!RegExp(r'^[\p{L}0-9 _-]{3,30}$', unicode: true).hasMatch(username)) {
      return 'El nombre de usuario debe tener entre 3 y 30 caracteres válidos';
    }
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'security_question': securityQuestion,
          'security_answer': securityAnswer, // el trigger de sql/10 lo cifra al guardar
        },
      );

      if (res.session != null && res.user != null) {
        await _loadProfile(res.user!.id);
        notifyListeners();
        return null;
      }
      // sin sesión = falta confirmar el email (según config del proyecto)
      return 'CONFIRM_EMAIL';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    isAuthenticated = false;
    profile = null;
    notifyListeners();
  }

  /// Igual que auth.js: 3 faltas = 24 horas sin poder comprar.
  bool isBanned() {
    final bannedUntil = profile?['banned_until'];
    if (bannedUntil == null) return false;
    return DateTime.parse(bannedUntil).isAfter(DateTime.now());
  }

  String? getBanMessage() {
    if (!isBanned()) return null;
    final until = DateTime.parse(profile!['banned_until']);
    final restante = until.difference(DateTime.now());
    final horas = restante.inHours;
    final minutos = restante.inMinutes % 60;
    return 'Tu cuenta está vetada por cancelaciones tardías. Podrás volver a comprar en ${horas}h ${minutos}min.';
  }

  Future<void> refreshProfile() async {
    final id = supabase.auth.currentUser?.id;
    if (id != null) {
      await _loadProfile(id);
      notifyListeners();
    }
  }

  // ======================================
  // BONO DE CRÉDITOS (igual que cart.html: 3.000 créditos = 5% de
  // descuento). Se descuenta exactamente 3.000, no todo el saldo — si
  // tenía 3.500, quedan 500 disponibles para seguir acumulando.
  // ======================================
  static const creditosParaBono = 3000;
  static const porcentajeBono = 5;

  bool get puedeCanjearBono => credits >= creditosParaBono;

  Future<bool> claimCreditsBonus() async {
    if (!puedeCanjearBono || profile == null) return false;
    final nuevoSaldo = credits - creditosParaBono;
    try {
      await supabase.from('usuarios').update({'credits': nuevoSaldo}).eq('id', profile!['id']);
      profile!['credits'] = nuevoSaldo;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al canjear créditos: $e');
      return false;
    }
  }
}
