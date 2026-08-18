import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _canjeando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
  }

  void _cargarDatos() {
    final auth = context.read<AuthService>();
    if (auth.profile != null) {
      final userId = auth.profile!['id'];
      context.read<DataService>().loadOrdersForUser(userId);
      context.read<DataService>().loadDiscountsForUser(userId);
    }
  }

  Future<void> _canjearBono() async {
    final auth = context.read<AuthService>();
    final data = context.read<DataService>();

    setState(() => _canjeando = true);
    final exito = await auth.claimCreditsBonus();

    if (exito) {
      final code = await data.addUserDiscount(
        auth.profile!['id'],
        AuthService.porcentajeBono,
        'creditos',
      );
      if (mounted && code != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Canjeaste tus créditos. Ganaste ${AuthService.porcentajeBono}% de descuento — código $code'),
            backgroundColor: AppColors.verdeNeon,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo canjear el bono'), backgroundColor: AppColors.magenta),
      );
    }
    if (mounted) setState(() => _canjeando = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final data = context.watch<DataService>();
    final cop = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteFondo),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.cyan.withOpacity(0.15),
              child: const Icon(Icons.person, size: 44, color: AppColors.cyan),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(auth.username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.cyan)),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Email', auth.email),
                    _infoRow('Rol', auth.isAdmin ? 'Administrador' : 'Cliente'),
                  ],
                ),
              ),
            ),
            if (auth.isBanned())
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.magenta.withOpacity(0.1),
                  border: Border.all(color: AppColors.magenta),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(auth.getBanMessage() ?? '', style: const TextStyle(color: AppColors.magenta)),
              ),

            // ==================== CRÉDITOS Y BONOS ====================
            if (!auth.isAdmin) ...[
              const SizedBox(height: 24),
              const Text('Créditos y Bonos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.verdeNeon)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Créditos ganados en juegos',
                              style: TextStyle(color: AppColors.textoGris)),
                          Text('${auth.credits}',
                              style: const TextStyle(
                                  color: AppColors.verdeNeon, fontWeight: FontWeight.w900, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (auth.credits / AuthService.creditosParaBono).clamp(0, 1).toDouble(),
                          minHeight: 8,
                          backgroundColor: AppColors.fondoClaro,
                          color: auth.puedeCanjearBono ? AppColors.verdeNeon : AppColors.cyan,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        auth.puedeCanjearBono
                            ? '¡Ya puedes canjear tu bono!'
                            : 'Te faltan ${AuthService.creditosParaBono - auth.credits} créditos para el próximo bono de ${AuthService.porcentajeBono}%',
                        style: const TextStyle(color: AppColors.textoGris, fontSize: 12),
                      ),

                      // Alerta cuando ya alcanzó los 3.000 créditos
                      if (auth.puedeCanjearBono) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.verdeNeon.withOpacity(0.1),
                            border: Border.all(color: AppColors.verdeNeon),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: AppColors.verdeNeon, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tienes ${AuthService.creditosParaBono} créditos o más — puedes canjearlos por ${AuthService.porcentajeBono}% de descuento.',
                                  style: const TextStyle(color: AppColors.textoClaro, fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdeNeon),
                            onPressed: _canjeando ? null : _canjearBono,
                            child: _canjeando
                                ? const SizedBox(
                                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                                    'Canjear ${AuthService.creditosParaBono} créditos por ${AuthService.porcentajeBono}% de descuento'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Bonos y descuentos ganados',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textoClaro)),
              const SizedBox(height: 8),
              if (data.discounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Todavía no has ganado ningún bono.', style: TextStyle(color: AppColors.textoGris)),
                )
              else
                ...data.discounts.map((d) {
                  final vencido = data.isDiscountExpired(d);
                  final usado = d['used'] == true;
                  final Color estadoColor = usado
                      ? AppColors.textoGris
                      : vencido
                          ? AppColors.magenta
                          : AppColors.verdeNeon;
                  final String estadoTexto = usado ? 'Canjeado' : (vencido ? 'Vencido' : 'Disponible');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      title: Text(d['code'] ?? '',
                          style: const TextStyle(color: AppColors.textoClaro, fontWeight: FontWeight.w700)),
                      subtitle: Text('${d['percentage']}% · origen: ${d['source']}',
                          style: const TextStyle(color: AppColors.textoGris, fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: estadoColor.withOpacity(0.15),
                          border: Border.all(color: estadoColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(estadoTexto,
                            style: TextStyle(color: estadoColor, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  );
                }),
            ],

            const SizedBox(height: 24),
            const Text('Historial de Compras',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.naranja)),
            const SizedBox(height: 12),
            if (data.orders.isEmpty)
              const Text('Todavía no tienes compras registradas.', style: TextStyle(color: AppColors.textoGris))
            else
              ...data.orders.map((o) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text('Orden #${o.id}',
                          style: const TextStyle(color: AppColors.textoClaro, fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${o.items.length} artículo(s) · ${o.paymentMethod == 'tienda' ? 'En tienda' : 'Tarjeta'} · ${o.status}',
                        style: const TextStyle(color: AppColors.textoGris),
                      ),
                      trailing: Text(cop.format(o.total),
                          style: const TextStyle(color: AppColors.verdeNeon, fontWeight: FontWeight.w800)),
                    ),
                  )),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.magenta,
                  side: const BorderSide(color: AppColors.magenta),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                onPressed: () async {
                  await context.read<AuthService>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.textoClaro)),
          ],
        ),
      ),
    );
  }
}
