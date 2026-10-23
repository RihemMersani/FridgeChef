
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/fridge_item.dart';

class FridgeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FridgeRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Identifier l'utilisateur connecté
  String get userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'Utilisateur non connecté.',
      );
    }

    return user.uid;
  }

  // Collection du frigo personnel
  CollectionReference<Map<String, dynamic>>
      get _fridgeCollection {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('fridge');
  }

  // CREATE : ajouter un ingrédient
  Future<void> addIngredient(FridgeItem item) async {
    if (item.ingredientId.isEmpty ||
        item.quantity <= 0 ||
        item.unit.isEmpty) {
      throw ArgumentError(
        'Ingrédient ou quantité invalide.',
      );
    }

    await _fridgeCollection
        .doc(item.ingredientId)
        .set(item.toMap());
  }

  // READ : récupérer les ingrédients
  Future<List<FridgeItem>> getFridgeItems() async {
    final snapshot = await _fridgeCollection.get();

    return snapshot.docs.map((doc) {
      return FridgeItem.fromMap(doc.data());
    }).toList();
  }

  // READ : écouter les changements en temps réel
  Stream<List<FridgeItem>> watchFridgeItems() {
    return _fridgeCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return FridgeItem.fromMap(doc.data());
        }).toList();
      },
    );
  }

  // UPDATE : modifier la quantité et l'unité
  Future<void> updateIngredient({
    required String ingredientId,
    required double quantity,
    required String unit,
  }) async {
    if (quantity <= 0 || unit.isEmpty) {
      throw ArgumentError(
        'Quantité ou unité invalide.',
      );
    }

    await _fridgeCollection.doc(ingredientId).update({
      'quantity': quantity,
      'unit': unit,
    });
  }

  // DELETE : supprimer un ingrédient
  Future<void> deleteIngredient(
    String ingredientId,
  ) async {
    await _fridgeCollection
        .doc(ingredientId)
        .delete();
  }

  // Vérifier si un ingrédient est déjà présent
  Future<bool> containsIngredient(
    String ingredientId,
  ) async {
    final doc = await _fridgeCollection
        .doc(ingredientId)
        .get();

    return doc.exists;
  }
}
