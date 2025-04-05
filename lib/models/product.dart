import 'ingredient.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String category; // e.g., "skincare", "haircare", "makeup"
  final String imageUrl;
  final List<Ingredient> ingredients;
  final DateTime analyzedDate;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.ingredients,
    this.imageUrl = '',
    required this.analyzedDate,
  });

  // Convert Product instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'analyzedDate': analyzedDate.toIso8601String(),
    };
  }

  // Create Product instance from a map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      category: map['category'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      ingredients:
          (map['ingredients'] as List?)
              ?.map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      analyzedDate:
          map['analyzedDate'] != null
              ? DateTime.parse(map['analyzedDate'] as String)
              : DateTime.now(),
    );
  }

  // Calculate overall safety score based on ingredients
  String get safetyScore {
    if (ingredients.isEmpty) return 'Unknown';

    final unsafeCount = ingredients.where((i) => i.isUnsafe).length;
    final cautionCount = ingredients.where((i) => i.requiresCaution).length;

    if (unsafeCount > 0) return 'Unsafe';
    if (cautionCount > 0) return 'Caution';
    return 'Safe';
  }

  // Get list of concerning ingredients
  List<Ingredient> get concerningIngredients {
    return ingredients.where((i) => !i.isSafe).toList();
  }
}
