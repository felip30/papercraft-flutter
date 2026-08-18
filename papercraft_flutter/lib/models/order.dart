/// Mismos campos que dataManager.js mapea desde la tabla "pedidos".
class Order {
  final int id;
  final String userId;
  final String userName;
  final List<dynamic> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final String status;
  final String paymentMethod;
  final DateTime date;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.date,
  });

  factory Order.fromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as int,
        userId: m['usuario_id'] ?? '',
        userName: m['usuario_nombre'] ?? '',
        items: (m['items'] as List<dynamic>?) ?? [],
        subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
        tax: (m['iva'] as num?)?.toDouble() ?? 0,
        shipping: (m['envio'] as num?)?.toDouble() ?? 0,
        discount: (m['descuento'] as num?)?.toDouble() ?? 0,
        total: (m['total'] as num?)?.toDouble() ?? 0,
        status: m['status'] ?? 'pendiente',
        paymentMethod: m['metodo_pago'] ?? 'tarjeta',
        date: DateTime.parse(m['created_at']),
      );
}
