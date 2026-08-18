import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../models/product.dart';
import 'package:intl/intl.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _categoria = '';
  String _busqueda = '';

  final _cop = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (b) => AppColors.gradienteCyanMagenta.createShader(b),
          child: const Text('TIENDA NEOCRAFT',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteFondo),
        child: Consumer<DataService>(
          builder: (context, data, _) {
            if (data.loadingProducts) {
              return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
            }

            final productos = data.products.where((p) {
              final matchCategoria = _categoria.isEmpty || p.categoria == _categoria;
              final matchBusqueda =
                  _busqueda.isEmpty || p.nombre.toLowerCase().contains(_busqueda.toLowerCase());
              return matchCategoria && matchBusqueda;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    style: const TextStyle(color: AppColors.textoClaro),
                    decoration: const InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: Icon(Icons.search, color: AppColors.cyan),
                    ),
                    onChanged: (v) => setState(() => _busqueda = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _chip('Todas', ''),
                        _chip('Papelería', 'papelería'),
                        _chip('Tecnología', 'tecnología'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: productos.isEmpty
                      ? const Center(
                          child: Text('No se encontraron productos', style: TextStyle(color: AppColors.textoGris)))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: productos.length,
                          itemBuilder: (context, i) => _ProductCard(product: productos[i], cop: _cop),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _categoria == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _categoria = value),
        selectedColor: AppColors.cyan,
        backgroundColor: AppColors.fondoClaro,
        labelStyle: TextStyle(color: selected ? AppColors.fondoOscuro : AppColors.textoGris),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final NumberFormat cop;
  const _ProductCard({required this.product, required this.cop});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imagen.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imagen,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => const Icon(Icons.inventory_2, color: AppColors.cyan, size: 40),
                      )
                    : const Center(child: Icon(Icons.inventory_2, color: AppColors.cyan, size: 40)),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.categoria, style: const TextStyle(color: AppColors.textoGris, fontSize: 11)),
            Text(product.nombre,
                style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(cop.format(product.precio),
                style: const TextStyle(color: AppColors.verdeNeon, fontWeight: FontWeight.w900, fontSize: 16)),
            Text('Stock: ${product.stock}', style: const TextStyle(color: AppColors.textoGris, fontSize: 11)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                onPressed: product.stock <= 0
                    ? null
                    : () {
                        final auth = context.read<AuthService>();
                        if (!auth.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inicia sesión para agregar al carrito')));
                          return;
                        }
                        if (auth.isBanned()) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(auth.getBanMessage()!)));
                          return;
                        }
                        context.read<DataService>().addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.nombre} agregado'), duration: const Duration(seconds: 1)),
                        );
                      },
                child: Text(product.stock <= 0 ? 'Sin stock' : 'Agregar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
