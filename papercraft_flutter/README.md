# PaperCraft Systems — Flutter

Versión Flutter del proyecto, conectada a la **misma base de datos Supabase**
que usa el sitio web — mismos productos, usuarios, pedidos. Un cambio hecho
desde el Panel Admin de la web se ve acá también, y viceversa.

## Cómo correrlo

1. Necesitas tener Flutter instalado (`flutter --version` para confirmar).
2. Desde esta carpeta:
   ```
   flutter pub get
   flutter run
   ```
3. Regístrate desde la app, o inicia sesión con una cuenta que ya tengas
   en la web (es la misma base de datos).

## Qué incluye esta primera versión

- Conexión a Supabase con las mismas credenciales del sitio web.
- Login y registro (con pregunta de seguridad).
- Tienda: catálogo con búsqueda, filtro por categoría, stock en tiempo real.
- Carrito: agregar/quitar productos, totales con IVA y envío, pago simulado
  (tarjeta o en tienda) que crea el pedido real en la base de datos y
  descuenta el stock.
- Mi Perfil: datos de la cuenta, créditos, aviso de veto si aplica,
  historial de compras real, cerrar sesión.
- **Créditos y Bonos**: barra de progreso hacia los 3.000 créditos,
  alerta visible cuando ya se puede canjear, botón para canjear (igual
  que en el carrito de la web: 3.000 créditos = 5% de descuento), y
  lista de todos los bonos ganados con su estado (Disponible / Canjeado
  / Vencido).

## Lo que queda pendiente (para una siguiente pasada)

Este es un proyecto grande — construir *todo* con buena calidad en un
solo bloque no era realista. Lo que falta, en orden de lo más importante
a lo más opcional:

1. **Los 4 juegos** (Ruleta, Memoria, Trivia, Dado) con sus animaciones y
   el límite diario controlado por Supabase.
2. **Panel de administrador** (inventario, usuarios, pedidos, informe de
   juegos) — hoy la app solo tiene la vista de cliente.
3. **Sesión única por dispositivo** y sistema de faltas/cancelación con
   temporizador de 7 minutos (la base de datos ya lo soporta, falta la
   pantalla).
4. Factura en PDF con QR y código de recogida.
5. Recuperar contraseña, subir foto de perfil, Vault Gamer.

Dime por cuál seguimos.
