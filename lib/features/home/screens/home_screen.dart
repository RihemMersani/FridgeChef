
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../ingredients/screens/ingredients_screen.dart';
import '../../ingredients/repositories/ingredient_repository.dart';
import '../../fridge/screens/my_fridge_screen.dart';
import '../../fridge/repositories/fridge_repository.dart';
import '../../recipes/services/recipe_ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FridgeRepository fridgeRepository =
      FridgeRepository();

  final IngredientRepository ingredientRepository =
      IngredientRepository();

  final RecipeAIService recipeAIService =
      RecipeAIService();

  bool isGenerating = false;

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de se déconnecter.',
          ),
        ),
      );
    }
  }

  void openMyFridge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyFridgeScreen(),
      ),
    );
  }

  void openIngredients() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IngredientsScreen(),
      ),
    );
  }

  String formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }

    return quantity.toString();
  }

  // Génération réelle de recettes avec Gemini AI
  Future<void> generateRecipesWithAI() async {
    if (isGenerating) return;

    setState(() {
      isGenerating = true;
    });

    try {
      // 1. Récupérer le frigo personnel
      final fridgeItems =
          await fridgeRepository.getFridgeItems();

      if (!mounted) return;

      if (fridgeItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Votre frigo est vide ! '
              'Ajoutez des ingrédients avant de générer.',
            ),
          ),
        );
        return;
      }

      // 2. Récupérer le catalogue des ingrédients
      final ingredients =
          await ingredientRepository.getIngredients();

      final ingredientMap = {
        for (final ingredient in ingredients)
          ingredient.id: ingredient.name,
      };

      // 3. Préparer les ingrédients et quantités
      final availableIngredients = fridgeItems.map((item) {
        final name =
            ingredientMap[item.ingredientId] ??
            item.ingredientId;

        return '$name : '
            '${formatQuantity(item.quantity)} '
            '${item.unit}';
      }).toList();

      debugPrint(
        'FridgeChef : ${availableIngredients.length} '
        'ingrédients envoyés à Gemini.',
      );

      // 4. Appeler Gemini via Firebase AI Logic
      final generatedRecipes =
          await recipeAIService.generateRecipes(
        availableIngredients,
      );

      if (!mounted) return;

      // 5. Afficher le résultat brut pour ce premier test
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recettes générées !',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: SelectableText(
                  generatedRecipes,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Erreur Gemini AI : $e');

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Erreur Gemini AI'),
            content: SingleChildScrollView(
              child: SelectableText(
                e.toString(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name =
        user?.displayName?.trim().isNotEmpty == true
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
            onPressed: isGenerating ? null : logout,
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
                  const Icon(
                    Icons.restaurant_menu,
                    size: 75,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 20),

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
                          'Gérez vos ingrédients et découvrez '
                          'ce que vous pouvez cuisiner.',
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

                  // Ouvrir le frigo
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed:
                          isGenerating ? null : openMyFridge,
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

                  // Voir le catalogue
                  SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed:
                          isGenerating ? null : openIngredients,
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text(
                        'Voir les ingrédients',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Carte Gemini AI
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 42,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Votre Chef IA',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Gemini analyse votre frigo '
                          'et vous propose des recettes '
                          'personnalisées.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: isGenerating
                                ? null
                                : generateRecipesWithAI,
                            icon: isGenerating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.auto_awesome,
                                  ),
                            label: Text(
                              isGenerating
                                  ? 'Génération en cours...'
                                  : 'Générer mes recettes avec IA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
