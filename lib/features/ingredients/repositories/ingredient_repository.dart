
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';

class IngredientRepository {
  final FirebaseFirestore _firestore;

  IngredientRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _ingredientsCollection =>
          _firestore.collection('ingredients');

  List<Ingredient> _parseIngredients(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final ingredients = snapshot.docs.map((doc) {
      return Ingredient.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    ingredients.sort(
      (a, b) => a.name
          .toLowerCase()
          .compareTo(b.name.toLowerCase()),
    );

    return ingredients;
  }

  // Lire tous les ingrédients depuis le serveur
  Future<List<Ingredient>> getIngredients() async {
    final snapshot = await _ingredientsCollection.get(
      const GetOptions(source: Source.server),
    );

    debugPrint(
      'COLLECTION : ${snapshot.docs.length} documents',
    );

    return _parseIngredients(snapshot);
  }

  // Diagnostic : lire directement la tomate
  Future<void> testDirectDocument() async {
    debugPrint('===== TEST DOCUMENT TOMATE =====');

    try {
      final doc = await _ingredientsCollection
          .doc('tomate')
          .get(
            const GetOptions(source: Source.server),
          );

      debugPrint('Chemin : ${doc.reference.path}');
      debugPrint('Document existe : ${doc.exists}');
      debugPrint('Données : ${doc.data()}');
    } on FirebaseException catch (e) {
      debugPrint('Erreur Firebase : ${e.code}');
      debugPrint('Message : ${e.message}');
    } catch (e) {
      debugPrint('Erreur inattendue : $e');
    }

    debugPrint('===== FIN TEST TOMATE =====');
  }

  // Écouter les ingrédients en temps réel
  Stream<List<Ingredient>> watchIngredients() async* {
    debugPrint('===== DIAGNOSTIC FIRESTORE =====');

    debugPrint(
      'Projet : ${_firestore.app.options.projectId}',
    );

    debugPrint('Base : ${_firestore.databaseId}');

    // Test direct avant la lecture de la collection
    await testDirectDocument();

    yield* _ingredientsCollection
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      debugPrint(
        'Documents reçus : ${snapshot.docs.length}',
      );

      debugPrint(
        'Depuis le cache : '
        '${snapshot.metadata.isFromCache}',
      );

      for (final doc in snapshot.docs) {
        debugPrint('Document trouvé : ${doc.id}');
      }

      return _parseIngredients(snapshot);
    });
  }

  // Récupérer un ingrédient par ID
  Future<Ingredient?> getIngredientById(
    String id,
  ) async {
    final doc = await _ingredientsCollection.doc(id).get(
      const GetOptions(source: Source.server),
    );

    if (!doc.exists) {
      return null;
    }

    return Ingredient.fromMap(
      doc.id,
      doc.data()!,
    );
  }
}
