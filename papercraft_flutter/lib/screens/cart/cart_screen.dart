import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cop = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteFondo),
        child: Consumer<DataService>(
          builder: (context, data, _) {
            if (data.cart.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 60, color: AppColors.cyan),
                    const SizedBox(height: 16),
                    const Text('Tu carrito está vacío', style: TextStyle(fontSize: 18, color: AppColors.textoClaro)),
                    const SizedBox(height: 8),
                    const Text('Explora nuestros productos y agrega artículos',
                        style: TextStyle(color: AppColors.textoGris)),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.cart.length,
                    itemBuilder: (context, i) {
                      final item = data.cart[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(item.product.nombre, style: const TextStyle(color: AppColors.textoClaro)),
                          subtitle: Text(cop.format(item.product.precio), style: const TextStyle(color: AppColors.verdeNeon)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.cyan),
                                onPressed: () => data.updateQuantity(item.product.id, item.quantity - 1),
                              ),
                              Text('${item.quantity}', style: const TextStyle(color: AppColors.textoClaro)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.cyan),
                                onPressed: () => data.updateQuantity(item.product.id, item.quantity + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.magenta),
                                onPressed: () => data.removeFromCart(item.product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.magenta, width: 1.5)),
                  ),
                  child: Column(
                    children: [
                      _totalRow('Subtotal', cop.format(data.cartSubtotal)),
                      _totalRow('IVA (19%)', cop.format(data.cartTax)),
                      _totalRow('Envío', cop.format(data.cartShipping)),
                      const Divider(color: AppColors.textoGris),
                      _totalRow('TOTAL', cop.format(data.cartTotal), bold: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showPaymentSheet(context),
                          child: const Text('Pagar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? AppColors.textoClaro : AppColors.textoGris,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
                  fontSize: bold ? 18 : 14)),
          Text(value,
              style: TextStyle(
                  color: bold ? AppColors.magenta : AppColors.textoClaro,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
                  fontSize: bold ? 18 : 14)),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fondoMedio,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Elige cómo pagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.cyan)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.credit_card),
                label: const Text('Pagar con tarjeta'),
                onPressed: () => _confirmOrder(ctx, 'tarjeta'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdeNeon),
                icon: const Icon(Icons.store),
                label: const Text('Pagar en tienda (sin tarjeta)'),
                onPressed: () => _confirmOrder(ctx, 'tienda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, String metodoPago) async {
    final auth = context.read<AuthService>();
    final data = context.read<DataService>();
    Navigator.pop(context);

    final order = await data.createOrder(
      userId: auth.profile!['id'],
      userName: auth.username,
      metodoPago: metodoPago,
    );

    if (!context.mounted) return;
    if (order != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra realizada. Orden #${order.id}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar la compra')),
      );
    }
  }
}
