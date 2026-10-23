
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../ingredients/screens/ingredients_screen.dart';
import '../../fridge/screens/my_fridge_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Déconnexion Firebase
  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de se déconnecter. Réessayez.',
          ),
        ),
      );
    }
  }

  // Ouvrir la page Mon Frigo
  void openMyFridge(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyFridgeScreen(),
      ),
    );
  }

  // Ouvrir le catalogue des ingrédients
  void openIngredients(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IngredientsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Chef';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'FridgeChef',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout,
              color: AppColors.primary,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
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

                  const SizedBox(height: 20),

                  // Message de bienvenue
                  Text(
                    'Bonjour $name !',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Bienvenue dans votre cuisine intelligente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Carte Mon Frigo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.kitchen_outlined,
                          color: AppColors.primary,
                          size: 50,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Mon Frigo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Gérez les ingrédients de votre '
                          'réfrigérateur et découvrez '
                          'ce que vous pouvez cuisiner !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bouton Mon Frigo
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => openMyFridge(context),
                      icon: const Icon(
                        Icons.kitchen_outlined,
                      ),
                      label: const Text(
                        'Ouvrir mon frigo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bouton catalogue
                  SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          openIngredients(context),
                      icon: const Icon(
                        Icons.list_alt_outlined,
                      ),
                      label: const Text(
                        'Voir les ingrédients',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Recettes : fonctionnalité future
                  SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Les recettes arrivent bientôt !',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.restaurant_menu,
                      ),
                      label: const Text(
                        'Découvrir les recettes',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
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
