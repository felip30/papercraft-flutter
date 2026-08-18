import 'package:flutter/material.dart';
import '../main.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

/// Equivalente a js/dataManager.js — productos y pedidos vienen de la
/// MISMA base de datos que usa el sitio web, así que un cambio hecho
/// desde el panel admin (web) aparece acá también, y viceversa.
class DataService extends ChangeNotifier {
  List<Product> products = [];
  final List<CartItem> cart = [];
  List<Order> orders = [];
  bool loadingProducts = true;

  Future<void> loadProducts() async {
    loadingProducts = true;
    notifyListeners();
    try {
      final data = await supabase.from('productos').select().eq('status', 'activo');
      products = (data as List).map((m) => Product.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }
    loadingProducts = false;
    notifyListeners();
  }

  // ==================== CARRITO ====================

  void addToCart(Product product) {
    final existing = cart.where((c) => c.product.id == product.id).toList();
    if (existing.isNotEmpty) {
      if (existing.first.quantity < product.stock) {
        existing.first.quantity++;
      }
    } else if (product.stock > 0) {
      cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final item = cart.firstWhere((c) => c.product.id == productId);
    item.quantity = quantity.clamp(1, item.product.stock);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  double get cartSubtotal => cart.fold(0, (sum, item) => sum + item.subtotal);
  double get cartTax => cartSubtotal * 0.19;
  double get cartShipping => cart.isEmpty ? 0 : (cartSubtotal >= 100000 ? 0 : 8000);
  double get cartTotal => cartSubtotal + cartTax + cartShipping;

  // ==================== PEDIDOS ====================

  Future<void> loadOrdersForUser(String userId) async {
    try {
      final data = await supabase
          .from('pedidos')
          .select()
          .eq('usuario_id', userId)
          .order('created_at', ascending: false);
      orders = (data as List).map((m) => Order.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
    }
  }

  /// Crea el pedido y descuenta stock, igual que createOrder() en la web.
  Future<Order?> createOrder({
    required String userId,
    required String userName,
    required String metodoPago,
  }) async {
    try {
      final itemsFormateados = cart
          .map((c) => {
                'productId': c.product.id,
                'name': c.product.nombre,
                'price': c.product.precio,
                'quantity': c.quantity,
              })
          .toList();

      final data = await supabase
          .from('pedidos')
          .insert({
            'usuario_id': userId,
            'usuario_nombre': userName,
            'items': itemsFormateados,
            'subtotal': cartSubtotal,
            'iva': cartTax,
            'envio': cartShipping,
            'descuento': 0,
            'total': cartTotal,
            'status': 'pendiente',
            'metodo_pago': metodoPago,
          })
          .select()
          .single();

      // descuenta el stock de cada producto comprado
      for (final item in cart) {
        final nuevoStock = (item.product.stock - item.quantity).clamp(0, 999999);
        await supabase.from('productos').update({'stock': nuevoStock}).eq('id', item.product.id);
      }

      final order = Order.fromMap(data);
      orders.insert(0, order);
      clearCart();
      await loadProducts(); // refresca el stock mostrado
      return order;
    } catch (e) {
      debugPrint('Error al crear el pedido: $e');
      return null;
    }
  }

  // ==================== DESCUENTOS (premios ganados) ====================

  List<Map<String, dynamic>> discounts = [];

  Future<void> loadDiscountsForUser(String userId) async {
    try {
      final data = await supabase
          .from('descuentos')
          .select()
          .eq('usuario_id', userId)
          .order('created_at', ascending: false);
      discounts = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar descuentos: $e');
    }
  }

  bool isDiscountExpired(Map<String, dynamic> d) {
    final expiresAt = d['expires_at'];
    if (expiresAt == null) return false;
    return DateTime.parse(expiresAt).isBefore(DateTime.now());
  }

  /// Genera un código nuevo y lo guarda — igual que addUserDiscount() en
  /// la web (usado tanto por el bono de créditos como, más adelante, por
  /// los premios de los juegos).
  Future<String?> addUserDiscount(String userId, int percentage, String source) async {
    final code =
        '${source.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(3)}';
    try {
      final data = await supabase
          .from('descuentos')
          .insert({
            'usuario_id': userId,
            'code': code,
            'percentage': percentage,
            'source': source,
            'used': false,
          })
          .select()
          .single();
      discounts.insert(0, data);
      notifyListeners();
      return data['code'] as String;
    } catch (e) {
      debugPrint('Error al crear descuento: $e');
      return null;
    }
  }
}
