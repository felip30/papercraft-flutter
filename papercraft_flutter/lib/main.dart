import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'screens/splash_screen.dart';

/// Misma base de datos que usa la versión web (js/supabase-config.js) —
/// productos, usuarios, pedidos, juegos, todo es EL MISMO dato real,
/// sin importar si entras desde el sitio o desde esta app.
const supabaseUrl = 'https://gkfhvswmxjqzsbfmhzph.supabase.co';
const supabaseAnonKey = 'sb_publishable_Ih22pgpCe5JeSImMjE7hWQ_M7yb4Odo';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const PaperCraftApp());
}

final supabase = Supabase.instance.client;

class PaperCraftApp extends StatelessWidget {
  const PaperCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..init()),
        ChangeNotifierProvider(create: (_) => DataService()),
      ],
      child: MaterialApp(
        title: 'PaperCraft Systems',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
