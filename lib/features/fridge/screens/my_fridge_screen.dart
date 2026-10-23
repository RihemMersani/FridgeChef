
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../ingredients/models/ingredient.dart';
import '../../ingredients/repositories/ingredient_repository.dart';
import '../models/fridge_item.dart';
import '../repositories/fridge_repository.dart';

class MyFridgeScreen extends StatefulWidget {
  const MyFridgeScreen({super.key});

  @override
  State<MyFridgeScreen> createState() => _MyFridgeScreenState();
}

class _MyFridgeScreenState extends State<MyFridgeScreen> {
  final FridgeRepository fridgeRepository =
      FridgeRepository();

  final IngredientRepository ingredientRepository =
      IngredientRepository();

  late final Stream<List<FridgeItem>> fridgeStream;
  late final Stream<List<Ingredient>> ingredientStream;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fridgeStream = fridgeRepository.watchFridgeItems();
    ingredientStream =
        ingredientRepository.watchIngredients();
  }

  String formatQuantity(double quantity) {
    return quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toString();
  }

  String formatUnit(String unit, double quantity) {
    if (unit == 'piece') {
      return quantity > 1 ? 'pièces' : 'pièce';
    }
    return unit;
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Formulaire partagé pour ajout et modification
  Future<FridgeItem?> showIngredientForm({
    required Ingredient ingredient,
    FridgeItem? existingItem,
  }) async {
    final controller = TextEditingController(
      text: existingItem == null
          ? '1'
          : formatQuantity(existingItem.quantity),
    );

    String unit = existingItem?.unit ?? 'piece';

    final result = await showDialog<FridgeItem>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingItem == null
                    ? 'Ajouter ${ingredient.name}'
                    : 'Modifier ${ingredient.name}',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantité',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: unit,
                    decoration: const InputDecoration(
                      labelText: 'Unité',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'piece',
                        child: Text('Pièce'),
                      ),
                      DropdownMenuItem(
                        value: 'g',
                        child: Text('Gramme (g)'),
                      ),
                      DropdownMenuItem(
                        value: 'ml',
                        child: Text('Millilitre (ml)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          unit = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final quantity = double.tryParse(
                      controller.text
                          .trim()
                          .replaceAll(',', '.'),
                    );

                    if (quantity == null ||
                        !quantity.isFinite ||
                        quantity <= 0) {
                      ScaffoldMessenger.of(dialogContext)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Veuillez saisir une quantité positive.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      FridgeItem(
                        ingredientId: ingredient.id,
                        quantity: quantity,
                        unit: unit,
                      ),
                    );
                  },
                  child: Text(
                    existingItem == null
                        ? 'Ajouter'
                        : 'Enregistrer',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Éviter de libérer le contrôleur pendant
    // l'animation de fermeture du dialogue.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(
        const Duration(milliseconds: 400),
        controller.dispose,
      );
    });

    return result;
  }

  // Ajouter un ingrédient
  Future<void> addIngredient(Ingredient ingredient) async {
    final item = await showIngredientForm(
      ingredient: ingredient,
    );

    if (item == null || !mounted) return;

    setState(() => isSaving = true);

    try {
      await fridgeRepository.addIngredient(item);
      showMessage('${ingredient.name} ajouté au frigo !');
    } catch (e) {
      showMessage(
        "Impossible d'ajouter cet ingrédient : $e",
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // Modifier un ingrédient
  Future<void> editIngredient(
    Ingredient ingredient,
    FridgeItem existingItem,
  ) async {
    final updated = await showIngredientForm(
      ingredient: ingredient,
      existingItem: existingItem,
    );

    if (updated == null || !mounted) return;

    setState(() => isSaving = true);

    try {
      await fridgeRepository.updateIngredient(
        ingredientId: updated.ingredientId,
        quantity: updated.quantity,
        unit: updated.unit,
      );

      showMessage('${ingredient.name} modifié !');
    } catch (e) {
      showMessage(
        'Impossible de modifier cet ingrédient : $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // Supprimer un ingrédient
  Future<void> deleteIngredient(
    Ingredient ingredient,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer cet ingrédient ?'),
          content: Text(
            'Voulez-vous retirer ${ingredient.name} '
            'de votre frigo ?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => isSaving = true);

    try {
      await fridgeRepository.deleteIngredient(ingredient.id);
      showMessage('${ingredient.name} supprimé du frigo.');
    } catch (e) {
      showMessage(
        'Impossible de supprimer cet ingrédient : $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // Sélectionner un ingrédient du catalogue
  void openIngredientSelector(
    List<Ingredient> ingredients,
    List<FridgeItem> fridgeItems,
  ) {
    final existingIds =
        fridgeItems.map((e) => e.ingredientId).toSet();

    final available = ingredients
        .where((e) => !existingIds.contains(e.id))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: Column(
                children: [
                  const Text(
                    'Choisir un ingrédient',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: available.isEmpty
                        ? const Center(
                            child: Text(
                              'Tous les ingrédients sont déjà '
                              'dans votre frigo.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: available.length,
                            itemBuilder: (context, index) {
                              final ingredient =
                                  available[index];

                              return ListTile(
                                leading: const Icon(
                                  Icons.eco_outlined,
                                  color: AppColors.primary,
                                ),
                                title: Text(ingredient.name),
                                subtitle:
                                    Text(ingredient.category),
                                trailing: const Icon(Icons.add),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  addIngredient(ingredient);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mon Frigo',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<Ingredient>>(
        stream: ingredientStream,
        builder: (context, ingredientSnapshot) {
          return StreamBuilder<List<FridgeItem>>(
            stream: fridgeStream,
            builder: (context, fridgeSnapshot) {
              if (ingredientSnapshot.hasError ||
                  fridgeSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erreur de chargement Firebase.',
                  ),
                );
              }

              if (!ingredientSnapshot.hasData ||
                  !fridgeSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final ingredients = ingredientSnapshot.data!;
              final fridgeItems = fridgeSnapshot.data!;

              final ingredientMap = {
                for (final ingredient in ingredients)
                  ingredient.id: ingredient,
              };

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 550,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${fridgeItems.length} '
                              'ingrédient(s) dans mon frigo',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        openIngredientSelector(
                                          ingredients,
                                          fridgeItems,
                                        );
                                      },
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  'Ajouter un ingrédient',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSaving)
                        const LinearProgressIndicator(
                          color: AppColors.primary,
                        ),
                      Expanded(
                        child: fridgeItems.isEmpty
                            ? const Center(
                                child: Text(
                                  'Votre frigo est vide !',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: fridgeItems.length,
                                itemBuilder: (context, index) {
                                  final item = fridgeItems[index];

                                  final ingredient =
                                      ingredientMap[
                                          item.ingredientId] ??
                                      Ingredient(
                                        id: item.ingredientId,
                                        name: item.ingredientId,
                                        category: '',
                                        imageUrl: '',
                                      );

                                  return Card(
                                    color: Colors.white,
                                    margin:
                                        const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.kitchen_outlined,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ingredient.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${formatQuantity(item.quantity)} '
                                                  '${formatUnit(item.unit, item.quantity)}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Modifier',
                                            onPressed: isSaving
                                                ? null
                                                : () => editIngredient(
                                                      ingredient,
                                                      item,
                                                    ),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Supprimer',
                                            onPressed: isSaving
                                                ? null
                                                : () => deleteIngredient(
                                                      ingredient,
                                                    ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
