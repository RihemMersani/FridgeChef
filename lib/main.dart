
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Activer App Check
  // WebDebugProvider en dev pour éviter les 403.
  // En production : remplacer par ReCaptchaV3Provider('SITE_KEY').
  await FirebaseAppCheck.instance.activate(
    providerWeb: kDebugMode
        ? WebDebugProvider()
        : ReCaptchaV3Provider('REMPLACER_PAR_SITE_KEY'),
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
  );

  if (kDebugMode) {
    debugPrint('FridgeChef : App Check debug activé.');
  }

  // 3. Démarrer FridgeChef
  runApp(const FridgeChefApp());
}

class FridgeChefApp extends StatelessWidget {
  const FridgeChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgeChef',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Gestion automatique de la session Firebase
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Erreur de connexion à Firebase.',
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
