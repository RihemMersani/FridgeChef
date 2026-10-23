
class FridgeItem {
  final String ingredientId;
  final double quantity;
  final String unit;

  const FridgeItem({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
  });

  // Convertir les données Firestore en objet Dart
  factory FridgeItem.fromMap(
    Map<String, dynamic> data,
  ) {
    return FridgeItem(
      ingredientId: data['ingredientId'] as String? ?? '',
      quantity:
          (data['quantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'piece',
    );
  }

  // Convertir un objet Dart en données Firestore
  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // Créer une copie modifiée de l'objet
  FridgeItem copyWith({
    String? ingredientId,
    double? quantity,
    String? unit,
  }) {
    return FridgeItem(
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() {
    return 'FridgeItem('
        'ingredientId: $ingredientId, '
        'quantity: $quantity, '
        'unit: $unit'
        ')';
  }
}
