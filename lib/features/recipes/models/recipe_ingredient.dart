
class RecipeIngredient {
  final String ingredientId;
  final double quantity;
  final String unit;
  final bool optional;

  const RecipeIngredient({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.optional = false,
  });

  factory RecipeIngredient.fromMap(
    Map<String, dynamic> data,
  ) {
    return RecipeIngredient(
      ingredientId: data['ingredientId'] as String? ?? '',
      quantity:
          (data['quantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'piece',
      optional: data['optional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unit': unit,
      'optional': optional,
    };
  }

  RecipeIngredient copyWith({
    String? ingredientId,
    double? quantity,
    String? unit,
    bool? optional,
  }) {
    return RecipeIngredient(
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      optional: optional ?? this.optional,
    );
  }
}
