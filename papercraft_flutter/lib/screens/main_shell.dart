import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';
import 'shop/shop_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

/// Equivalente al navbar del sitio: Tienda, Carrito, Mi Perfil — todo
/// dentro de una sola pantalla con navegación inferior, como es habitual
/// en apps móviles (en vez de un menú horizontal como en la web).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataService>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ShopScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.fondoOscuro,
          border: Border(top: BorderSide(color: AppColors.cyan, width: 1.5)),
        ),
        child: SafeArea(
          child: Consumer<DataService>(
            builder: (context, data, _) => BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.cyan,
              unselectedItemColor: AppColors.textoGris,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Tienda'),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${data.cart.length}'),
                    isLabelVisible: data.cart.isNotEmpty,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: 'Carrito',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
