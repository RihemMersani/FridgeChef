
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Configuration Firebase
import 'firebase_options.dart';

// Thème de l'application
import 'core/theme/app_theme.dart';

// Page de connexion
import 'features/auth/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lancement de l'application
  runApp(const FridgeChefApp());
}

class FridgeChefApp extends StatelessWidget {
  const FridgeChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgeChef',

      // Supprimer la bannière DEBUG
      debugShowCheckedModeBanner: false,

      // Appliquer notre thème personnalisé
      theme: AppTheme.lightTheme,

      // Page affichée au démarrage
      home: const LoginScreen(),
    );
  }
}
