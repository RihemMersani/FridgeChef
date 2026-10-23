
class Ingredient {
  final String id;
  final String name;
  final String category;
  final String imageUrl;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });

  // Transformer un document Firestore en objet Ingredient
  factory Ingredient.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Ingredient(
      id: id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  // Transformer un objet Ingredient en données Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  // Créer une copie avec certains champs modifiés
  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'Ingredient('
        'id: $id, '
        'name: $name, '
        'category: $category'
        ')';
  }
}
