
import 'package:firebase_ai/firebase_ai.dart';

class RecipeAIService {
  // Modèle Gemini utilisé via Firebase AI Logic
  final GenerativeModel _model =
      FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.8-flash',
    generationConfig: GenerationConfig(
      temperature: 0.7,
      responseMimeType: 'application/json',
    ),
  );

  // Générer des recettes à partir des ingrédients
  Future<String> generateRecipes(
    List<String> ingredients,
  ) async {
    if (ingredients.isEmpty) {
      throw Exception(
        'Veuillez ajouter des ingrédients à votre frigo.',
      );
    }

    final ingredientList = ingredients.join(', ');

    final prompt = '''
Tu es FridgeChef, un chef cuisinier intelligent.

Ta mission est de proposer 3 recettes adaptées
aux ingrédients disponibles dans le réfrigérateur.

Ingrédients disponibles :
$ingredientList

Instructions :
- Propose des recettes simples et réalisables.
- Privilégie les recettes tunisiennes quand c'est possible.
- Utilise en priorité les ingrédients disponibles.
- Indique clairement tout ingrédient supplémentaire nécessaire.
- N'invente pas de quantités disponibles.
- Donne une durée de préparation réaliste.
- Explique les étapes de préparation en français.
- Retourne uniquement un objet JSON valide.

Format JSON attendu :

{
  "recipes": [
    {
      "name": "Nom de la recette",
      "description": "Description courte",
      "category": "Déjeuner",
      "durationMinutes": 20,
      "difficulty": "Facile",
      "ingredients": [
        {
          "name": "Tomate",
          "quantity": 2,
          "unit": "piece",
          "available": true
        }
      ],
      "steps": [
        "Première étape",
        "Deuxième étape"
      ]
    }
  ]
}
''';

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception(
          "Gemini n'a retourné aucune recette.",
        );
      }

      return text;
    } catch (e) {
      throw Exception(
        'Erreur pendant la génération des recettes : $e',
      );
    }
  }
}
