/// Mismos campos que dataManager.js mapea desde la tabla "productos".
class Product {
  final int id;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;
  final String icon;
  final String imagen;
  final String description;
  final String status;

  Product({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
    required this.icon,
    required this.imagen,
    required this.description,
    required this.status,
  });

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as int,
        nombre: m['nombre'] ?? '',
        categoria: m['categoria'] ?? '',
        precio: (m['precio'] as num?)?.toDouble() ?? 0,
        stock: (m['stock'] as num?)?.toInt() ?? 0,
        icon: m['icon'] ?? 'package',
        imagen: m['imagen'] ?? '',
        description: m['description'] ?? '',
        status: m['status'] ?? 'activo',
      );
}
