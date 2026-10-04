import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/supabase_client.dart';
import 'providers/auth_provider.dart';
import 'providers/branch_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth_gate.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await NotificationService.instance.initialize();
  runApp(const OikkoApp());
}

class OikkoApp extends StatelessWidget {
  const OikkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
      ],
      child: MaterialApp(
        title: 'Oikko',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2F6FED),
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFFF7F8FA),
            foregroundColor: Colors.black87,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}