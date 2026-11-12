
import 'recipe_ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final int durationMinutes;
  final String difficulty;
  final List<String> steps;
  final List<RecipeIngredient> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.durationMinutes,
    required this.difficulty,
    required this.steps,
    required this.ingredients,
  });

  factory Recipe.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Recipe(
      id: id,
      name: data['name'] as String? ?? '',
      description:
          data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      durationMinutes:
          (data['durationMinutes'] as num?)?.toInt() ?? 0,
      difficulty:
          data['difficulty'] as String? ?? 'Facile',
      steps: List<String>.from(data['steps'] ?? []),
      ingredients: (data['ingredients'] as List? ?? [])
          .map(
            (item) => RecipeIngredient.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'steps': steps,
      'ingredients': ingredients
          .map((ingredient) => ingredient.toMap())
          .toList(),
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    int? durationMinutes,
    String? difficulty,
    List<String>? steps,
    List<RecipeIngredient>? ingredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMinutes:
          durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
