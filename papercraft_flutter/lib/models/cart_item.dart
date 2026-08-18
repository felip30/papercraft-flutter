import 'product.dart';

/// El carrito vive solo en memoria de la app (igual que en la web, que lo
/// guarda en localStorage) — se vacía al reiniciar la app, a propósito.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.precio * quantity;
}
