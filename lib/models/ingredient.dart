class Ingredient {
  final String name;
  final String description;
  final String riskLevel; // "Safe", "Caution", or "Unsafe"
  final List<String> concerns; // Potential health concerns
  final List<String> alternatives; // Safer alternatives
  final String imageUrl; // Optional image URL
  
  const Ingredient({
    required this.name,
    required this.description,
    required this.riskLevel,
    this.concerns = const [],
    this.alternatives = const [],
    this.imageUrl = '',
  });
  
  // Convert Ingredient instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'riskLevel': riskLevel,
      'concerns': concerns,
      'alternatives': alternatives,
      'imageUrl': imageUrl,
    };
  }
  
  // Create Ingredient instance from a map
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      riskLevel: map['riskLevel'] as String? ?? 'Unknown',
      concerns: List<String>.from(map['concerns'] ?? []),
      alternatives: List<String>.from(map['alternatives'] ?? []),
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
  
  // Helper method to determine if ingredient is safe
  bool get isSafe => riskLevel == 'Safe';
  
  // Helper method to determine if ingredient requires caution
  bool get requiresCaution => riskLevel == 'Caution';
  
  // Helper method to determine if ingredient is unsafe
  bool get isUnsafe => riskLevel == 'Unsafe';
}