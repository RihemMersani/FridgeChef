
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../models/ingredient.dart';
import '../repositories/ingredient_repository.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() =>
      _IngredientsScreenState();
}

class _IngredientsScreenState
    extends State<IngredientsScreen> {
  final IngredientRepository repository =
      IngredientRepository();

  final TextEditingController searchController =
      TextEditingController();

  late final Stream<List<Ingredient>> ingredientsStream;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    ingredientsStream = repository.watchIngredients();

    // Informations pour diagnostiquer la connexion
    final user = FirebaseAuth.instance.currentUser;

    debugPrint('===== FRIDGECHEF DEBUG =====');
    debugPrint('Utilisateur connecté : ${user != null}');
    debugPrint(
      'Firebase projectId : '
      '${FirebaseFirestore.instance.app.options.projectId}',
    );
    debugPrint('Collection : ingredients');
    debugPrint('============================');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  IconData getIngredientIcon(String category) {
    switch (category.toLowerCase()) {
      case 'légumes':
        return Icons.eco_outlined;
      case 'fruits':
        return Icons.apple_outlined;
      case 'produits laitiers':
        return Icons.egg_alt_outlined;
      case 'produits animaux':
        return Icons.egg_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  Widget buildIngredientCard(Ingredient ingredient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(
                alpha: 0.25,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              getIngredientIcon(ingredient.category),
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  ingredient.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mes ingrédients',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un ingrédient...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Ingredient>>(
              stream: ingredientsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint(
                    'ERREUR FIRESTORE : ${snapshot.error}',
                  );

                  final error = snapshot.error;

                  String message = error.toString();

                  if (error is FirebaseException) {
                    message =
                        'Code : ${error.code}\n'
                        'Message : ${error.message}';
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SelectableText(
                        'Erreur Firestore\n\n$message',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final ingredients = snapshot.data!;

                final filtered = ingredients.where((item) {
                  return item.name
                          .toLowerCase()
                          .contains(searchQuery) ||
                      item.category
                          .toLowerCase()
                          .contains(searchQuery);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        'Documents Firestore reçus : '
                        '${ingredients.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun ingrédient trouvé.',
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return buildIngredientCard(
                                  filtered[index],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
