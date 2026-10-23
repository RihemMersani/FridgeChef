
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  // Afficher un message
  void showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? AppColors.primary : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Connexion avec Firebase Authentication
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Vérification des champs
    if (email.isEmpty || password.isEmpty) {
      showMessage(
        'Veuillez remplir tous les champs.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Connexion Firebase
      final UserCredential credential =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final user = credential.user;

      if (user != null) {
        showMessage(
          'Connexion réussie ! Bienvenue sur FridgeChef.',
          success: true,
        );

        // La navigation vers Home sera ajoutée
        // à la prochaine étape.
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage =
              'Adresse email invalide.';
          break;

        case 'user-disabled':
          errorMessage =
              'Ce compte a été désactivé.';
          break;

        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage =
              'Email ou mot de passe incorrect.';
          break;

        case 'too-many-requests':
          errorMessage =
              'Trop de tentatives. Réessayez plus tard.';
          break;

        case 'network-request-failed':
          errorMessage =
              'Erreur de connexion Internet.';
          break;

        default:
          errorMessage =
              'Erreur de connexion : ${e.code}';
      }

      showMessage(errorMessage);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Une erreur inattendue est survenue.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Style des champs
  InputDecoration inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.restaurant_menu,
                    size: 75,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  // Nom application
                  const Text(
                    'FridgeChef',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Cuisinez avec ce que vous avez !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Titre
                  const Text(
                    'Bon retour !',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Connectez-vous pour découvrir vos recettes.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Email
                  TextField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: inputDecoration(
                      'Adresse e-mail',
                      Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Mot de passe
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: inputDecoration(
                      'Mot de passe',
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton connexion
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : loginUser,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation inscription
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore de compte ?',
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
