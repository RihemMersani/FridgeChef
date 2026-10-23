
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  // Afficher un message à l'utilisateur
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

  // Inscription avec Firebase Authentication
  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    // Vérification des champs vides
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Veuillez remplir tous les champs.');
      return;
    }

    // Vérification de l'adresse email
    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      showMessage('Veuillez saisir une adresse email valide.');
      return;
    }

    // Vérification du mot de passe
    if (password.length < 6) {
      showMessage(
        'Le mot de passe doit contenir au moins 6 caractères.',
      );
      return;
    }

    // Vérification de la confirmation
    if (password != confirmPassword) {
      showMessage(
        'Les mots de passe ne correspondent pas.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Création du compte Firebase
      final UserCredential credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enregistrement du nom dans Firebase Auth
      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      showMessage(
        'Compte créé avec succès !',
        success: true,
      );

      // Retour vers la page de connexion
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'Cette adresse email est déjà utilisée.';
          break;

        case 'invalid-email':
          errorMessage =
              'Adresse email invalide.';
          break;

        case 'weak-password':
          errorMessage =
              'Le mot de passe est trop faible.';
          break;

        case 'operation-not-allowed':
          errorMessage =
              "L'inscription par email n'est pas activée.";
          break;

        case 'network-request-failed':
          errorMessage =
              'Erreur de connexion Internet.';
          break;

        default:
          errorMessage =
              'Erreur Firebase : ${e.code}';
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                    size: 65,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 12),

                  // Nom de l'application
                  const Text(
                    'FridgeChef',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Titre
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Rejoignez FridgeChef et découvrez '
                    'de délicieuses recettes !',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Nom complet
                  TextField(
                    controller: nameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: inputDecoration(
                      'Nom complet',
                      Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Adresse email
                  TextField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: inputDecoration(
                      'Adresse e-mail',
                      Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  // Confirmation mot de passe
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: hideConfirmPassword,
                    decoration: inputDecoration(
                      'Confirmer le mot de passe',
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword =
                                !hideConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Bouton inscription
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : registerUser,
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
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Retour vers connexion
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ?',
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: const Text(
                          'Se connecter',
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
